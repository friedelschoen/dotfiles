package main

import (
	"archive/zip"
	"bufio"
	"compress/gzip"
	"crypto/sha1"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"slices"
	"strings"

	"gopkg.in/yaml.v3"
)

var (
	buildDir    = "build/sources"
	outDir      = "build/apps"
	logdir      = "build/log"
	configDir   = "configs"
	patchDir    = "patches"
	hashesFile  = "build/hashes.txt"
	archiveExts = []string{".tar.gz", ".zip"}
)

func fatalf(msg string, args ...any) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

func readExistingHashes() map[string]string {
	res := map[string]string{}
	f, err := os.Open(hashesFile)
	if err != nil {
		return res
	}
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		parts := strings.Fields(scanner.Text())
		if len(parts) == 2 {
			res[parts[0]] = parts[1]
		}
	}
	return res
}

func hashFile(h io.Writer, filename string) {
	f, err := os.Open(filename)
	if err != nil {
		fatalf("cannot open file for hashing: %s", filename)
	}
	defer f.Close()
	io.Copy(h, f)
}

func optionHash(name string, app App) string {
	s := sha1.New()
	s.Write([]byte(name))
	enc := json.NewEncoder(s)
	enc.Encode(app)
	if app.Config != "" {
		hashFile(s, path.Join(configDir, app.Config))
	}
	if app.Patches != nil {
		for _, patch := range app.Patches {
			hashFile(s, path.Join(patchDir, patch))
		}
	}
	return hex.EncodeToString(s.Sum(nil))
}

func downloadFile(name, url string) string {
	for _, ext := range archiveExts {
		if strings.HasSuffix(url, ext) {
			dest := path.Join(buildDir, "archives", name+ext)
			fmt.Printf("[*] downloading %s\n", url)
			resp, err := http.Get(url)
			if err != nil || resp.StatusCode != 200 {
				fatalf("failed to download %s", url)
			}
			defer resp.Body.Close()
			os.MkdirAll(path.Dir(dest), 0755)
			out, _ := os.Create(dest)
			defer out.Close()
			io.Copy(out, resp.Body)
			return dest
		}
	}
	fatalf("unsupported archive format for %s", url)
	return ""
}

func unpackTarGz(archive, dest string) {
	f, err := os.Open(archive)
	if err != nil {
		fatalf("could not open archive: %s", archive)
	}
	gz, _ := gzip.NewReader(f)
	err = Untar(gz, dest)
	if err != nil {
		fatalf("could not open archive: %s", archive)
	}
}

func unpackZip(archive, dest string) {
	r, err := zip.OpenReader(archive)
	if err != nil {
		fatalf("cannot unzip: %s", archive)
	}
	defer r.Close()
	for _, f := range r.File {
		dirname := path.Join(dest, f.Name)
		if f.FileInfo().IsDir() {
			os.MkdirAll(dirname, 0755)
			continue
		}
		os.MkdirAll(path.Dir(dirname), 0755)
		out, _ := os.Create(dirname)
		in, _ := f.Open()
		io.Copy(out, in)
		out.Close()
		in.Close()
	}
}

func unpack(archive, name string) {
	dest := path.Join(buildDir, name)
	os.RemoveAll(dest)
	os.MkdirAll(dest, 0755)
	if strings.HasSuffix(archive, ".tar.gz") {
		unpackTarGz(archive, dest)
	} else if strings.HasSuffix(archive, ".zip") {
		unpackZip(archive, dest)
	} else {
		fatalf("Unsupported archive: %s", archive)
	}
}

func validateChecksum(filename, expected string) {
	f, _ := os.Open(filename)
	h := sha1.New()
	io.Copy(h, f)
	f.Close()
	actual := fmt.Sprintf("%x", h.Sum(nil))
	if actual != expected {
		fatalf("checksum mismatch:\n  Expected: %s\n  Got:      %s", expected, actual)
	}
}

func applyPatch(dir, patch string) {
	rel, _ := filepath.Rel(dir, path.Join(patchDir, patch))
	fmt.Printf("[*] applying %s\n", patch)
	cmd := exec.Command("patch", "-p1", "-i", rel)
	cmd.Dir = dir
	if err := cmd.Run(); err != nil {
		fatalf("unable to patch")
	}
}

func copyFile(src, dst string) {
	b, _ := os.ReadFile(src)
	os.WriteFile(dst, b, 0644)
}

func processProgram(name string, app App, existing map[string]string, db io.Writer) {
	hash := optionHash(name, app)
	if existing[name] == hash {
		fmt.Printf("Skipping %s, already exists\n", name)
		return
	}
	dest := path.Join(buildDir, name)
	if app.Path != "" {
		os.RemoveAll(dest)
		os.Symlink(app.Path, dest)
	} else {
		archive := downloadFile(name, app.URL)
		validateChecksum(archive, app.Checksum)
		unpack(archive, name)
	}
	if entries, err := os.ReadDir(dest); err == nil && len(entries) == 1 {
		dest = path.Join(dest, entries[0].Name())
	}

	for _, patch := range app.Patches {
		applyPatch(dest, patch)
	}

	if app.Config != "" {
		copyFile(path.Join(configDir, app.Config), path.Join(dest, "config.h"))
	}

	os.MkdirAll(logdir, 0755)
	logfile, err := os.Create(path.Join(logdir, name+".txt"))
	if err != nil {
		logfile = os.Stderr
	}

	fmt.Printf("[*] building %s\n", name)
	cwd, _ := os.Getwd()
	cmd := exec.Command("sh", "-c", app.Install)
	cmd.Env = append(os.Environ(), "root="+cwd, "out="+path.Join(cwd, outDir))
	cmd.Dir = dest
	cmd.Stdin = nil
	cmd.Stdout = logfile
	cmd.Stderr = logfile
	err = cmd.Run()
	if err != nil {
		fatalf("install failed: %s", err)
	}
	if logfile != os.Stderr {
		logfile.Close()
	}

	fmt.Fprintf(db, "%s %s\n", name, hash)
}

type App struct {
	URL      string   `yaml:"url"`
	Path     string   `yaml:"path"`
	Checksum string   `yaml:"checksum"`
	Patches  []string `yaml:"patches"`
	Config   string   `yaml:"config"`
	Install  string   `yaml:"install"`
}

func main() {
	if len(os.Args) < 2 {
		fatalf("Usage: makeapps [-f] <file.yml>")
	}
	force := os.Args[1] == "-f"
	if force {
		os.Args = slices.Delete(os.Args, 1, 2)
	}
	raw, _ := os.ReadFile(os.Args[1])
	var apps map[string]App
	yaml.Unmarshal(raw, &apps)
	os.MkdirAll(buildDir, 0755)
	existing := map[string]string{}
	if !force {
		existing = readExistingHashes()
	}
	db, err := os.Create(hashesFile)
	if err != nil {
		panic(err)
	}
	defer db.Close()
	for name, app := range apps {
		processProgram(name, app, existing, db)
	}
}
