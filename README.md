- **version: 2.0.2**
## Chain
- Là một tập các Chuỗi xích lệnh, giúp đưa logic mã về dạng chuỗi
- *Là Object có cấu trúc tương tự nhau, clone từ Chain - Main Class*

## Sử dụng
- Gọi và kết nối function và tham số nối tiếp nhau(thuận tiện khi gọi bằng hàm viết tắt - short function)
- function được kết nối *luôn* được truyền cùng đầu tiên tương tự ```this```
- Kết quả của *mắt xích này* sẽ là được **bổ sung** vào tham số của *mắt xích sau*
```lua
Chain:run(function()
    print("Running!")
end):run(function()
    print("And then!")
end):start()
```
- **Thứ tự tham số**: ```<this> <tham số chính> <lỗi> <tham số kết quả trước>
- ```VD: this, ev..., err, result...```
- **Thứ tự tham số tín hiệu - Signal**: ```<this> <tham số tín hiệu> <tham số chính> <lỗi> <tham số kết quả trước>```
- ```VD: this, ev..., para..., err, result...```
```lua
Chain:run(function(this, para1)
    print("Running!", para1) --> 10
    return "Result"
end, 10):run(function(this, para2, err, result1)
    print("And then!")
    print(para2, result1) --> 20, "Result"
end, 20):start()
```
## Cài đặt - Settings
```lua
export type ChainSettings = {
    RequiredList:{string}, -- danh sách các Chain cần được tải ngay
}
```
## Class
- Các lớp dẫn xuất tương tự nhau, *chỉ khác ở việc biến đổi tham số về dạng chuẩn*
- **Dạng chuẩn**: 
```lua
(f:function, para...)
```
- Cấu trúc một lớp dẫn xuất bằng ghi đè phương thức ```param```, nên tham khảo từ ```Proto``` - lớp nguyên mẫu.
```lua
Chain:param(...):(f:function, para...) --> dạng chuẩn
```
### Chain - Lớp chính
```lua
-- Bắt đầu/ khởi động
start() -- st, start
-- Kết nối Chuỗi - Chain
run(f, ...) -- r, run
spawn(f, ...) -- s, spawn
defer(f, ...) -- df, defer
delay(sec, f, ...) -- dl, delay
try(f, ...) -- t, try
event(signal:Signal, fcn, f, ...) -- e, event
-- Kết hợp - Blend
runBlend(blend:string|Chain, f, ...) -- rb, runBlend
spawnBlend(blend:string|Chain, f, ...) -- sb, spawnBlend
deferBlend(blend:string|Chain, f, ...) -- dfb, deferBlend
delayBlend(blend:string|Chain, sec, f, ...) -- dlb, delayBlend
tryBlend(blend:string|Chain, f, ...) -- tb, tryBlend
eventBlend(blend:string|Chain, signal:Signal, fcn, f, ...) -- eb, eventBlend
```
### Event - Xử lý Sự kiện, Tín hiệu
- D
```lua
-- Bắt đầu/ khởi động
start() -- st, start
-- Kết nối Chuỗi - Chain
run(f, ...) -- r, run
spawn(f, ...) -- s, spawn
defer(f, ...) -- df, defer
delay(sec, f, ...) -- dl, delay
try(f, ...) -- t, try
event(signal:Signal, fcn, f, ...) -- e, event
-- Kết hợp - Blend
runBlend(blend:string|Chain, f, ...) -- rb, runBlend
spawnBlend(blend:string|Chain, f, ...) -- sb, spawnBlend
deferBlend(blend:string|Chain, f, ...) -- dfb, deferBlend
delayBlend(blend:string|Chain, sec, f, ...) -- dlb, delayBlend
tryBlend(blend:string|Chain, f, ...) -- tb, tryBlend
eventBlend(blend:string|Chain, signal:Signal, fcn, f, ...) -- eb, eventBlend
```