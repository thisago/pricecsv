## CSV products total calculator

import std/parsecsv
import std/terminal

from std/tables import Table, `[]`, `[]=`, hasKey
from std/strformat import fmt
from std/streams import newFileStream
from std/strutils import parseFloat, toLowerAscii, replace
from std/algorithm import sort

type Item = Table[string, string]

proc tryGet[K, T](t: Table[K, T]; k: K): T =
  try:
    result = t[k]
  except: discard

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

func has(items: seq[Item]; item: Item; nameCol, priceCol, discountCol: string): bool =
  ## Check if the seq have a item with same name
  result = false
  for it in items:
    if it[nameCol] == item[nameCol] and it[priceCol] == item[priceCol] and it.tryGet(discountCol) == item.tryGet(discountCol):
      return true

proc addItem(items: var seq[Item]; item: Item; nameCol, quantityCol, priceCol, discountCol: string) =
  ## Increments the quantity of a item
  for it in items.mitems:
    if it[nameCol] == item[nameCol] and it[priceCol] == item[priceCol] and it.tryGet(discountCol) == item.tryGet(discountCol):
      if it.hasKey quantityCol:
        it[quantityCol] = $(1 + parseInt it[quantityCol])
      else:
        it[quantityCol] = "2"

proc dedup(items: var seq[Item]; quantityCol, nameCol, priceCol, discountCol: string) =
  var newItems: type items
  for item in items:
    if newItems.has(item, nameCol, priceCol, discountCol):
      newItems.addItem(item, nameCol, quantityCol, priceCol, discountCol)
    else:
      newItems.add item
  items = newItems

proc discount(price: float; discount: string): float =
  result = price
  if discount.len > 0:
    try:
      if discount[^1] == '%':
        let percentage = parseFloat discount[0..^2]
        result = price - (price / 100) * percentage
      else:
        result = price - parseFloat discount
    except:
      quit fmt"Error applying discount '{discount}'"

proc main(
  files: seq[string];
  nameCol = "name"; quantityCol = "quantity"; priceCol = "price";
  discountCol = "discount";
  dedup = true; sort = true; colors = true, excel = false
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
    dedup(items, quantityCol, nameCol, priceCol, discountCol)
  if sort:
    items.sort(proc (x, y: Item): int =
      cmp(x[nameCol].toLowerAscii, y[nameCol].toLowerAscii))

  var total: float

  proc printRow(
    qnt, price, discount, subtotal, name: string;
    fg = [fgWhite, fgYellow, fgWhite, fgGreen, fgWhite]
  ) =
    if excel:
      template noTab(s: string): untyped =
        s.replace("\t", "")
      echo(qnt.noTab, ",", price.noTab, ",", subtotal.noTab, ",", name.noTab)
    elif colors:
      styledEcho(fg[0], qnt, "\t", fg[1], price,
                             "\t", fg[2], discount,
                             "\t", fg[3], subtotal,
                             "\t", fg[4], name)
    else:
      echo(qnt, "\t", price, "\t", discount, "\t", subtotal, "\t", name)
  printRow("Qnt", "Price", "Discount", "Subtotal", "Name", [fgCyan, fgCyan, fgCyan, fgCyan, fgCyan])
  for i, item in items:
    var qnt = 1

    if item.hasKey quantityCol:
      qnt = parseInt item[quantityCol]

    let name = item[nameCol]
    var
      price = 0.0
      discount = "0"
    try:
      price = parseFloat item[priceCol]
    except:
      discard
    var newPrice = price
    if item.hasKey discountCol:
      discount = item[discountCol]
      newPrice = price.discount discount
      if excel:
        price = newPrice
    let subtotalNum = newPrice * float qnt
    let subtotal = if excel:
                    fmt"=A{i + 2}*B{i + 2}"
                  else:
                    fmt"{subtotalNum:2.2f}"
    printRow($qnt, fmt"{price:2.2f}", discount & "\t", subtotal & "\t", name)
    total += subtotalNum
  if excel:
    echo "\l" & fmt"Total,=sum(C2:C{items.len + 1}),,,"
  else:
    if colors:
      styledEcho styleUnderscore, "\lTotal", resetStyle, ": ", fgGreen, $total
    else:
      echo "\lTotal: ", $total

when isMainModule:
  import pkg/cligen
  dispatch main
