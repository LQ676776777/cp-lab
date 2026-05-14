declare i32 @getint()
declare float @getfloat()
declare i32 @getch()
declare i32 @getarray(i32*)
declare i32 @getfarray(float*)
declare void @putint(i32)
declare void @putfloat(float)
declare void @putch(i32)
declare void @putarray(i32, i32*)
declare void @putfarray(i32, float*)
declare void @_sysy_starttime()
declare void @_sysy_stoptime()
declare void @__aeabi_memcpy4(i32*, i32*, i32)
declare void @__aeabi_memclr4(i32*, i32)
declare void @__aeabi_memset4(i32*, i32, i32)
declare void @llvm.memset.p0.i32(i32*, i8, i32, i1)
define i32 @gcd(i32 %arg_0, i32 %arg_1) {
label_entry:
  %v2 = alloca i32
  %v3 = alloca i32
  %v4 = alloca i32
  store i32 %arg_0, i32* %v4
  store i32 %arg_1, i32* %v3
  %v5 = load i32, i32* %v4
  %v6 = load i32, i32* %v3
  %v7 = icmp eq i32 %v5, %v6
  br i1 %v7, label %label_9, label %label_11
label_ret:                                                ; preds = %label_9, %label_15, %label_21
  %v8 = load i32, i32* %v2
  ret i32 %v8
label_9:                                                ; preds = %label_entry
  %v10 = load i32, i32* %v4
  store i32 %v10, i32* %v2
  br label %label_ret
label_11:                                                ; preds = %label_entry
  %v12 = load i32, i32* %v4
  %v13 = load i32, i32* %v3
  %v14 = icmp sgt i32 %v12, %v13
  br i1 %v14, label %label_15, label %label_21
label_15:                                                ; preds = %label_11
  %v16 = load i32, i32* %v4
  %v17 = load i32, i32* %v3
  %v18 = sub i32 %v16, %v17
  %v19 = load i32, i32* %v3
  %v20 = call i32 @gcd(i32 %v18, i32 %v19)
  store i32 %v20, i32* %v2
  br label %label_ret
label_21:                                                ; preds = %label_11
  %v22 = load i32, i32* %v3
  %v23 = load i32, i32* %v4
  %v24 = sub i32 %v22, %v23
  %v25 = load i32, i32* %v4
  %v26 = call i32 @gcd(i32 %v24, i32 %v25)
  store i32 %v26, i32* %v2
  br label %label_ret
}
define i32 @main() {
label_entry:
  %v0 = alloca i32
  %v1 = alloca i32
  %v2 = alloca i32
  %v3 = call i32 @getint()
  store i32 %v3, i32* %v1
  %v4 = call i32 @getint()
  store i32 %v4, i32* %v0
  %v5 = load i32, i32* %v1
  %v6 = load i32, i32* %v0
  %v7 = call i32 @gcd(i32 %v5, i32 %v6)
  call void @putint(i32 %v7)
  call void @putch(i32 10)
  store i32 0, i32* %v2
  br label %label_ret
label_ret:                                                ; preds = %label_entry
  %v8 = load i32, i32* %v2
  ret i32 %v8
}

