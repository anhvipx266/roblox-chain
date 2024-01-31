- **version: 2.0**
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
- **Thứ tự tham số**: ```<this> [tham số chính] <lỗi> [tham số kết quả trước]```
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

```