## CSV products total calculator

import std/parsecsv
import std/terminal

from std/tables import Table, `[]`, `[]=`, hasKey
from std/strformat import fmt
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
      try:
        item[col] = p.rowEntry col
      except:
        quit fmt"No value for `{col}` in row {result.len + 1}"
    result.add item
  close p

func has(items: seq[Item]; item: Item; nameCol: string): bool =
  ## Check if the seq have a item with same name
  result = false
  for it in items:
    if it[nameCol] == item[nameCol]:
      return true

import std/[json, jsonutils]

proc addItem(items: var seq[Item]; item: Item; nameCol, quantityCol: string) =
  ## Increments the quantity of a item
  for it in items.mitems:
    if it[nameCol] == item[nameCol]:
      if it.hasKey quantityCol:
        it[quantityCol] = $(1 + parseInt it[quantityCol])
      else:
        it[quantityCol] = "2"

proc dedup(items: var seq[Item]; quantityCol, nameCol: string) =
  var newItems: type items
  for item in items:
    if newItems.has(item, nameCol):
      newItems.addItem(item, nameCol, quantityCol)
    else:
      newItems.add item
  items = newItems

proc main(files: seq[string]; nameCol = "name"; quantityCol = "quantity";
          priceCol = "price"; organize = true) =
  ## Calculates the total price of prices csv
  ##
  ## `quantity` col is optional
  if files.len == 0:
    quit "Please provide at least 1 file"

  var items: seq[Item]
  for file in files:
    for item in getItems file:
      items.add item

  if organize:
    dedup(items, quantityCol, nameCol)

  var total: float
  echo "Qnt\tPrice\tSubtotal\tName\l"
  for item in items:
    var qnt = 1
    if item.hasKey quantityCol:
      qnt = parseInt item[quantityCol]
    let
      price = parseFloat item[priceCol]
      subtotal = price * float qnt
    echo &"{int qnt}\t{price}\t{subtotal}\t\t{item[nameCol]}"
    total += subtotal
  echo &"\lTotal: {total}"


when isMainModule:
  import pkg/cligen
  dispatch main
