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

presentation:
    mkdir -p build && typst watch presentation/main.typ \
        --root ./ \
        build/presentation.pdf \
        && pympress build/presentation.pdf

poster:
    mkdir -p build && typst compile poster/main.typ \
        --root ./ \
        build/poster.pdf
        
poster-svg:
    mkdir -p build && typst compile poster/main.typ \
        --root ./ \
        --format svg \
        build/poster.svg


poster-png:
    mkdir -p build && typst compile poster/main.typ \
        --root ./ \
        --format png \
        build/poster.png 
