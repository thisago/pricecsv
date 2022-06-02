# pricecsv

Easily calculate the total of all products in csv

## Usage

### Help

```text
Usage:
  main [optional-params] [files: string...]
Calculates the total price of prices csv

`quantity` col is optional
Options:
  -h, --help                               print this cligen-erated help
  --help-syntax                            advanced: prepend,plurals,..
  -n=, --nameCol=      string  "name"      set nameCol
  -q=, --quantityCol=  string  "quantity"  set quantityCol
  -p=, --priceCol=     string  "price"     set priceCol
  -d=, --discountCol=  string  "discount"  set discountCol
  --dedup              bool    true        set dedup
  -s, --sort           bool    true        set sort
  -c, --colors         bool    true        set colors
```

### Example
```
pricecsv examples/items.csv
```

### Fields
Every field can be changed, but the default is:

- `name`: The product name. **Required**
- `price`: The product price. A float number. **Required**
- `quantity`: Quantity of product. **Default 1**
- `discount`: Discount of product. If ends with '%', will calculate the percentage, else it will subtract the value. **Default 0**

---

## TODO

- [ ] Add example
- [x] Add usage guide
- [ ] Add optional CSV print mode
- [ ] Add possibility to append the `subtotal` and `total` in the csv

## License

GPL-3
