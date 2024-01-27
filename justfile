alias b := build
alias w := watch
alias c := clean

input  := "./cv.typ"
output := "./nuke.pdf"

# Opens a PDF that auto updates on file changes
watch:
  @# Below `if` is an ugly hack for checking if a file exists... resolve
  @# https://github.com/casey/just/issues/1350 and https://github.com/casey/just/issues/1657
  @# for it to get better
  {{ if path_exists(output) == "true" {``} else {`just touch`} }}
  evince {{output}} &
  typst watch {{input}} {{output}}

[private]
touch:
  touch {{output}}

# Only build PDF
build:
  typst compile {{input}} {{output}}

clean:
  @rm -f {{output}}
