import std/[
  parsecsv,
  tables
]

from std/streams import newFileStream
from std/strutils import parseFloat, parseInt
from std/strformat import `&`

type Item = Table[string, string]

proc getItems(file: string): seq[Item] =
  var s = file.newFileStream fmRead
  if s == nil:
    quit("Cannot open the file: " & file)

  var p: CsvParser
  p.open file
  p.readHeaderRow()
  while p.readRow():
    var item: Item
    for col in p.headers:
      item[col] = p.rowEntry col
    result.add item
  close p

proc main(files: seq[string]; nameCol = "name"; quantityCol = "quantity";
          priceCol = "price") =
  ## Calculates the total price of prices csv
  if files.len == 0:
    quit "Please provide at least 1 file"

  var items: seq[Item]
  for file in files:
    for item in getItems file:
      items.add item

  var total: float
  echo "Qnt\tPrice\tSubtotal\tName\l"
  for item in items:
    var qnt = 1
    if item.hasKey quantityCol:
      qnt = parseInt item[quantityCol]
    let
      price = parseFloat item[priceCol]
      subtotal = price * float qnt
    echo &"{int qnt}\t{price}\t{subtotal}\t{item[nameCol]}"
    total += subtotal

  echo &"\lTotal: {total}"

when isMainModule:
  import pkg/cligen
  dispatch main
