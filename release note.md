- Lệnh khi unpack dữ liệu bị lỗi kì lạ, dẫn đến mất dữ liệu
```lua
f, table.unpack(params, 2), lastErr, table.unpack(lastResult)
```
- xử lý: pack dữ liệu bởi loop chính xác, kết hợp Option.None