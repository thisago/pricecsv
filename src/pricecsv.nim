import std/[
  parsecsv,
  tables
]

from std/streams import newFileStream
from std/strutils import parseFloat
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

proc main(file: seq[string]; nameCol = "name"; quantityCol = "quantity";
          priceCol = "price") =
  ## Calculates the total price of prices csv
  if file.len == 0:
    quit "Please provide the filename"
  let
    filename = file[0]
    items = getItems filename

  var total: float
  echo "Qnt\tPrice\tSubtotal\tName\l"
  for item in items:
    let
      qnt = parseFloat item[quantityCol]
      price = parseFloat item[priceCol]
      subtotal = qnt * price
    echo &"{int qnt}\t{price}\t{subtotal}\t{item[nameCol]}"
    total += subtotal

  echo &"\lTotal: {total}"

when isMainModule:
  import pkg/cligen
  dispatch main
