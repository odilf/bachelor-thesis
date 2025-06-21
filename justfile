date := `date +"%Y-%M-%d"`

entry-debug:
    mkdir -p build && typst watch entrypoint.typ --input DEBUG=true build/latest-active.pdf

# compiles paper in release mode, once.
paper-release:
    mkdir -p build && typst compile main.typ --input DEBUG=false build/paper.pdf

# builds paper in debug mode, watches and opens
paper-debug:
    mkdir -p build && typst watch main.typ \
        --input DEBUG=true \
        build/paper-debug.pdf \
        --open

# builds presentation in debug mode, watches and opens
presentation-release:
    @echo TODO

# builds presentation in debug mode, watches and opens
presentation-debug:
    @echo TODO
