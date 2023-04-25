import std/os
import std/osproc
import std/strutils
import std/posix
import std/inotify


func `$`(ev: ptr InotifyEvent): string =
  $cast[cstring](ev.name.addr) & " " & $ev.mask & " " & $ev.len

iterator pathParts(path: string): string= 
  var rest = path
  while rest != "" and rest != ".":
    let (newrest, tail) = rest.splitPath
    rest = newrest
    yield tail

func isAnyHidden(path: string): bool =
  for part in path.pathParts:
    if part.isHidden or part == "__pycache__":
      return true
  return false

proc main() =
  let toExecute = commandLineParams()
  let inoty = inotify_init()
  for filename in os.walkDirRec(".", yieldFilter={pcDir}):
    if not filename.isAnyHidden:
      if filename.dirExists:
        discard inotify_add_watch(inoty, filename.cstring, IN_CLOSE_WRITE)

  var evs = newSeq[byte](8192)
  while (let n = read(inoty, evs[0].addr, 8192); n) > 0:
    for e in inotify_events(evs[0].addr, n):
      echo "got event: " & $e
      discard execCmd(toExecute.join(" "))

when isMainModule:
  main()
