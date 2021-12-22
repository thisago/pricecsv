## CSV products total calculator

import std/parsecsv
import std/terminal

from std/tables import Table, `[]`, `[]=`, hasKey
from std/strformat import fmt
from std/streams import newFileStream
from std/strutils import parseFloat, toLowerAscii
# from std/strformat import `&`
from std/algorithm import sort

type Item = Table[string, string]

proc parseInt(str: string; default = 1): int =
  ## Try parse the string as integer, if not succeed, return default
  result = default
  try:
    result = strutils.parseInt str
  except:
    discard

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
      try:
        item[col] = p.rowEntry col
      except:
        quit fmt"No value for `{col}` in row {result.len + 1} in file `{file}`"
    result.add item
  close p

func has(items: seq[Item]; item: Item; nameCol, priceCol: string): bool =
  ## Check if the seq have a item with same name
  result = false
  for it in items:
    if it[nameCol] == item[nameCol] and it[priceCol] == item[priceCol]:
      return true

proc addItem(items: var seq[Item]; item: Item; nameCol, quantityCol: string) =
  ## Increments the quantity of a item
  for it in items.mitems:
    if it[nameCol] == item[nameCol]:
      if it.hasKey quantityCol:
        it[quantityCol] = $(1 + parseInt it[quantityCol])
      else:
        it[quantityCol] = "2"

proc dedup(items: var seq[Item]; quantityCol, nameCol, priceCol: string) =
  var newItems: type items
  for item in items:
    if newItems.has(item, nameCol, priceCol):
      newItems.addItem(item, nameCol, quantityCol)
    else:
      newItems.add item
  items = newItems

proc main(
  files: seq[string];
  nameCol = "name"; quantityCol = "quantity"; priceCol = "price";
  dedup = true; sort = true; colors = true
) =
  ## Calculates the total price of prices csv
  ##
  ## `quantity` col is optional
  if files.len == 0:
    quit "Please provide at least 1 file"

  var items: seq[Item]
  for file in files:
    for item in getItems file:
      items.add item

  if dedup:
    dedup(items, quantityCol, nameCol, priceCol)
  if sort:
    items.sort(proc (x, y: Item): int =
      cmp(x[nameCol].toLowerAscii, y[nameCol].toLowerAscii))

  var total: float

  proc printRow(
    qnt, price, subtotal, name: string;
    fg = [fgWhite, fgYellow, fgGreen, fgWhite]
  ) =
    if colors:
      styledEcho(fg[0], qnt, "\t", fg[1], price,
                             "\t", fg[2], subtotal,
                             "\t", fg[3], name)
    else:
      echo(qnt, "\t", price, "\t", subtotal, "\t", name)
  printRow("Qnt", "Price", "Subtotal", "Name", [fgCyan, fgCyan, fgCyan, fgCyan])
  for item in items:
    var qnt = 1
    if item.hasKey quantityCol:
      qnt = parseInt item[quantityCol]
    let
      price = parseFloat item[priceCol]
      subtotal = price * float qnt
    printRow($qnt, fmt"{price:2.2f}", fmt"{subtotal:2.2f}", "\t" & item[nameCol])
    total += subtotal
  styledEcho styleUnderscore, "\lTotal", resetStyle, ": ", $total


when isMainModule:
  import pkg/cligen
  dispatch main
