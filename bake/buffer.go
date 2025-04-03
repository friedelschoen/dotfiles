package main

type RingBuffer struct {
	Content []byte
	Index   int
	Size    int
}

func (b *RingBuffer) Write(p []byte) (int, error) {
	for _, chr := range p {
		b.Content[b.Index] = chr
		b.Index = (b.Index + 1) % len(b.Content)
		b.Size = min(b.Size+1, len(b.Content))
	}
	return len(p), nil
}

func (b *RingBuffer) Get() []byte {
	result := make([]byte, b.Size)
	for i := range b.Size {
		result[i] = b.Content[(i+b.Index)%len(b.Content)]
	}
	return result
}
