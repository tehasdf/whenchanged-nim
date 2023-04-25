import std/os
import std/sequtils
import std/posix
import std/inotify


func `$`(ev: ptr InotifyEvent): string =
  $cast[cstring](ev.name.addr) & " " & $ev.mask & " " & $ev.len

func pathParts(path: string): iterator(): string= 
  return iterator(): string = 
    var rest = path
    while rest != "" and rest != ".":
      let (newrest, tail) = rest.splitPath
      rest = newrest
      yield tail

func isAnyHidden(path: string): bool =
  path.pathParts.anyIt(it.isHidden)

proc main() =
  let inoty = inotify_init()
  for filename in os.walkDirRec(".", yieldFilter={pcDir}):
    if not filename.isAnyHidden:
      let fullfn = getCurrentDir() / filename
      if filename.dirExists:
        discard inotify_add_watch(inoty, filename.cstring, IN_CLOSE_WRITE)

  var evs = newSeq[byte](8192)
  while (let n = read(inoty, evs[0].addr, 8192); n) > 0:
    for e in inotify_events(evs[0].addr, n):
      echo $e

when isMainModule:
  main()
