; ModuleID = '/home/timothyduke/workspace/SeniorDesign/src/QueueTest.c'
source_filename = "/home/timothyduke/workspace/SeniorDesign/src/QueueTest.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.QueueData = type { i8*, i8*, i32, i32 }

@.str = private unnamed_addr constant [5 x i8] c"in_1\00", align 1
@.str.1 = private unnamed_addr constant [42 x i8] c"no parameters sent to QStartTask()\0Aabort\0A\00", align 1
@.str.2 = private unnamed_addr constant [5 x i8] c"in_2\00", align 1
@.str.3 = private unnamed_addr constant [40 x i8] c"no parameters sent to QAddTask()\0Aabort\0A\00", align 1
@.str.4 = private unnamed_addr constant [5 x i8] c"in_3\00", align 1
@.str.5 = private unnamed_addr constant [41 x i8] c"no parameters sent to QMultTask()\0Aabort\0A\00", align 1
@.str.6 = private unnamed_addr constant [5 x i8] c"in_4\00", align 1
@.str.7 = private unnamed_addr constant [42 x i8] c"no parameters sent to QPrintTask()\0Aabort\0A\00", align 1
@.str.8 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.9 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1

; Function Attrs: nounwind
define void @QStartTask(i8*) #0 !dbg !31 !xidane.fname !35 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32*, align 4
  %8 = alloca i8*, align 4
  %9 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !39, metadata !40), !dbg !41
  call void @llvm.dbg.declare(metadata i32* %3, metadata !42, metadata !40), !dbg !43
  call void @llvm.dbg.declare(metadata i32* %4, metadata !44, metadata !40), !dbg !45
  call void @llvm.dbg.declare(metadata i32* %5, metadata !46, metadata !40), !dbg !47
  call void @llvm.dbg.declare(metadata i32* %6, metadata !48, metadata !40), !dbg !49
  call void @llvm.dbg.declare(metadata i32** %7, metadata !50, metadata !40), !dbg !52
  call void @llvm.dbg.declare(metadata i8** %8, metadata !53, metadata !40), !dbg !54
  call void @llvm.dbg.declare(metadata %struct.QueueData* %9, metadata !55, metadata !40), !dbg !56
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str, i32 0, i32 0)), !dbg !57
  %10 = load i8*, i8** %2, align 4, !dbg !58
  %11 = icmp eq i8* %10, null, !dbg !60
  br i1 %11, label %12, label %13, !dbg !61

; <label>:12:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.1, i32 0, i32 0)), !dbg !62
  call void @vTaskDelete(i8* null), !dbg !64
  br label %13, !dbg !65

; <label>:13:                                     ; preds = %12, %1
  %14 = load i8*, i8** %2, align 4, !dbg !66
  %15 = bitcast i8* %14 to %struct.QueueData*, !dbg !67
  %16 = bitcast %struct.QueueData* %9 to i8*, !dbg !68
  %17 = bitcast %struct.QueueData* %15 to i8*, !dbg !68
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %16, i8* %17, i32 16, i32 4, i1 false), !dbg !68
  %18 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 1, !dbg !69
  %19 = load i8*, i8** %18, align 4, !dbg !69
  store i8* %19, i8** %8, align 4, !dbg !70
  %20 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 2, !dbg !71
  %21 = load i32, i32* %20, align 4, !dbg !71
  store i32 %21, i32* %3, align 4, !dbg !72
  %22 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 3, !dbg !73
  %23 = load i32, i32* %22, align 4, !dbg !73
  store i32 %23, i32* %4, align 4, !dbg !74
  store i32 0, i32* %5, align 4, !dbg !75
  br label %24, !dbg !76

; <label>:24:                                     ; preds = %42, %13
  %25 = load i32, i32* %5, align 4, !dbg !77
  %26 = icmp eq i32 %25, 1, !dbg !82
  br i1 %26, label %27, label %28, !dbg !83

; <label>:27:                                     ; preds = %24
  store i32 0, i32* %5, align 4, !dbg !84
  call void @vTaskDelay(i32 200), !dbg !86
  br label %28, !dbg !87

; <label>:28:                                     ; preds = %27, %24
  %29 = call i8* @pvPortMalloc(i32 40), !dbg !88
  %30 = bitcast i8* %29 to i32*, !dbg !88
  store i32* %30, i32** %7, align 4, !dbg !89
  store i32 0, i32* %6, align 4, !dbg !90
  br label %31, !dbg !92

; <label>:31:                                     ; preds = %39, %28
  %32 = load i32, i32* %6, align 4, !dbg !93
  %33 = icmp slt i32 %32, 10, !dbg !96
  br i1 %33, label %34, label %42, !dbg !97

; <label>:34:                                     ; preds = %31
  %35 = load i32, i32* %6, align 4, !dbg !98
  %36 = load i32, i32* %6, align 4, !dbg !100
  %37 = load i32*, i32** %7, align 4, !dbg !101
  %38 = getelementptr inbounds i32, i32* %37, i32 %36, !dbg !101
  store i32 %35, i32* %38, align 4, !dbg !102
  br label %39, !dbg !103

; <label>:39:                                     ; preds = %34
  %40 = load i32, i32* %6, align 4, !dbg !104
  %41 = add nsw i32 %40, 1, !dbg !104
  store i32 %41, i32* %6, align 4, !dbg !104
  br label %31, !dbg !106, !llvm.loop !107

; <label>:42:                                     ; preds = %31
  %43 = load i8*, i8** %8, align 4, !dbg !109
  %44 = bitcast i32** %7 to i8*, !dbg !109
  %45 = call i32 @xQueueGenericSend(i8* %43, i8* %44, i32 0, i32 0), !dbg !109
  br label %24, !dbg !110, !llvm.loop !112
                                                  ; No predecessors!
  ret void, !dbg !113
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !114 !xidane.function_declaration_type !115 !xidane.function_declaration_filename !116 !xidane.ExternC !38 void @xil_printf(i8*, ...) #2

declare !xidane.fname !117 !xidane.function_declaration_type !118 !xidane.function_declaration_filename !119 !xidane.ExternC !38 void @vTaskDelete(i8*) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #3

declare !xidane.fname !120 !xidane.function_declaration_type !121 !xidane.function_declaration_filename !119 !xidane.ExternC !38 void @vTaskDelay(i32) #2

declare !xidane.fname !122 !xidane.function_declaration_type !123 !xidane.function_declaration_filename !124 !xidane.ExternC !38 i8* @pvPortMalloc(i32) #2

declare !xidane.fname !125 !xidane.function_declaration_type !126 !xidane.function_declaration_filename !127 !xidane.ExternC !38 i32 @xQueueGenericSend(i8*, i8*, i32, i32) #2

; Function Attrs: nounwind
define void @QAddTask(i8*) #0 !dbg !128 !xidane.fname !129 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32*, align 4
  %8 = alloca i8*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !130, metadata !40), !dbg !131
  call void @llvm.dbg.declare(metadata i32* %3, metadata !132, metadata !40), !dbg !133
  call void @llvm.dbg.declare(metadata i32* %4, metadata !134, metadata !40), !dbg !135
  call void @llvm.dbg.declare(metadata i32* %5, metadata !136, metadata !40), !dbg !137
  call void @llvm.dbg.declare(metadata i32* %6, metadata !138, metadata !40), !dbg !139
  call void @llvm.dbg.declare(metadata i32** %7, metadata !140, metadata !40), !dbg !141
  call void @llvm.dbg.declare(metadata i8** %8, metadata !142, metadata !40), !dbg !143
  call void @llvm.dbg.declare(metadata i8** %9, metadata !144, metadata !40), !dbg !145
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.2, i32 0, i32 0)), !dbg !146
  call void @llvm.dbg.declare(metadata %struct.QueueData* %10, metadata !147, metadata !40), !dbg !148
  %11 = load i8*, i8** %2, align 4, !dbg !149
  %12 = icmp eq i8* %11, null, !dbg !151
  br i1 %12, label %13, label %14, !dbg !152

; <label>:13:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.3, i32 0, i32 0)), !dbg !153
  call void @vTaskDelete(i8* null), !dbg !155
  br label %14, !dbg !156

; <label>:14:                                     ; preds = %13, %1
  %15 = load i8*, i8** %2, align 4, !dbg !157
  %16 = bitcast i8* %15 to %struct.QueueData*, !dbg !158
  %17 = bitcast %struct.QueueData* %10 to i8*, !dbg !159
  %18 = bitcast %struct.QueueData* %16 to i8*, !dbg !159
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %17, i8* %18, i32 16, i32 4, i1 false), !dbg !159
  %19 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 0, !dbg !160
  %20 = load i8*, i8** %19, align 4, !dbg !160
  store i8* %20, i8** %8, align 4, !dbg !161
  %21 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 1, !dbg !162
  %22 = load i8*, i8** %21, align 4, !dbg !162
  store i8* %22, i8** %9, align 4, !dbg !163
  %23 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 2, !dbg !164
  %24 = load i32, i32* %23, align 4, !dbg !164
  store i32 %24, i32* %3, align 4, !dbg !165
  %25 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 3, !dbg !166
  %26 = load i32, i32* %25, align 4, !dbg !166
  store i32 %26, i32* %4, align 4, !dbg !167
  store i32 1, i32* %5, align 4, !dbg !168
  br label %27, !dbg !169

; <label>:27:                                     ; preds = %51, %34, %14
  %28 = load i32, i32* %5, align 4, !dbg !170
  %29 = icmp eq i32 %28, 1, !dbg !175
  br i1 %29, label %30, label %31, !dbg !176

; <label>:30:                                     ; preds = %27
  store i32 0, i32* %5, align 4, !dbg !177
  call void @vTaskDelay(i32 200), !dbg !179
  br label %31, !dbg !180

; <label>:31:                                     ; preds = %30, %27
  %32 = load i8*, i8** %8, align 4, !dbg !181
  %33 = icmp eq i8* %32, null, !dbg !183
  br i1 %33, label %34, label %35, !dbg !184

; <label>:34:                                     ; preds = %31
  store i32 1, i32* %5, align 4, !dbg !185
  br label %27, !dbg !187, !llvm.loop !188

; <label>:35:                                     ; preds = %31
  %36 = load i8*, i8** %8, align 4, !dbg !189
  %37 = bitcast i32** %7 to i8*, !dbg !190
  %38 = call i32 @xQueueReceive(i8* %36, i8* %37, i32 5), !dbg !191
  store i32 0, i32* %6, align 4, !dbg !192
  br label %39, !dbg !194

; <label>:39:                                     ; preds = %48, %35
  %40 = load i32, i32* %6, align 4, !dbg !195
  %41 = icmp slt i32 %40, 10, !dbg !198
  br i1 %41, label %42, label %51, !dbg !199

; <label>:42:                                     ; preds = %39
  %43 = load i32, i32* %6, align 4, !dbg !200
  %44 = load i32*, i32** %7, align 4, !dbg !202
  %45 = getelementptr inbounds i32, i32* %44, i32 %43, !dbg !202
  %46 = load i32, i32* %45, align 4, !dbg !203
  %47 = add nsw i32 %46, 1, !dbg !203
  store i32 %47, i32* %45, align 4, !dbg !203
  br label %48, !dbg !204

; <label>:48:                                     ; preds = %42
  %49 = load i32, i32* %6, align 4, !dbg !205
  %50 = add nsw i32 %49, 1, !dbg !205
  store i32 %50, i32* %6, align 4, !dbg !205
  br label %39, !dbg !207, !llvm.loop !208

; <label>:51:                                     ; preds = %39
  %52 = load i8*, i8** %9, align 4, !dbg !210
  %53 = bitcast i32** %7 to i8*, !dbg !210
  %54 = call i32 @xQueueGenericSend(i8* %52, i8* %53, i32 5, i32 0), !dbg !210
  br label %27, !dbg !211, !llvm.loop !188
                                                  ; No predecessors!
  ret void, !dbg !213
}

declare !xidane.fname !214 !xidane.function_declaration_type !215 !xidane.function_declaration_filename !127 !xidane.ExternC !38 i32 @xQueueReceive(i8*, i8*, i32) #2

; Function Attrs: nounwind
define void @QMultTask(i8*) #0 !dbg !216 !xidane.fname !217 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32*, align 4
  %8 = alloca i8*, align 4
  %9 = alloca i8*, align 4
  %10 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !218, metadata !40), !dbg !219
  call void @llvm.dbg.declare(metadata i32* %3, metadata !220, metadata !40), !dbg !221
  call void @llvm.dbg.declare(metadata i32* %4, metadata !222, metadata !40), !dbg !223
  call void @llvm.dbg.declare(metadata i32* %5, metadata !224, metadata !40), !dbg !225
  call void @llvm.dbg.declare(metadata i32* %6, metadata !226, metadata !40), !dbg !227
  call void @llvm.dbg.declare(metadata i32** %7, metadata !228, metadata !40), !dbg !229
  call void @llvm.dbg.declare(metadata i8** %8, metadata !230, metadata !40), !dbg !231
  call void @llvm.dbg.declare(metadata i8** %9, metadata !232, metadata !40), !dbg !233
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.4, i32 0, i32 0)), !dbg !234
  call void @llvm.dbg.declare(metadata %struct.QueueData* %10, metadata !235, metadata !40), !dbg !236
  %11 = load i8*, i8** %2, align 4, !dbg !237
  %12 = icmp eq i8* %11, null, !dbg !239
  br i1 %12, label %13, label %14, !dbg !240

; <label>:13:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.5, i32 0, i32 0)), !dbg !241
  call void @vTaskDelete(i8* null), !dbg !243
  br label %14, !dbg !244

; <label>:14:                                     ; preds = %13, %1
  %15 = load i8*, i8** %2, align 4, !dbg !245
  %16 = bitcast i8* %15 to %struct.QueueData*, !dbg !246
  %17 = bitcast %struct.QueueData* %10 to i8*, !dbg !247
  %18 = bitcast %struct.QueueData* %16 to i8*, !dbg !247
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %17, i8* %18, i32 16, i32 4, i1 false), !dbg !247
  %19 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 0, !dbg !248
  %20 = load i8*, i8** %19, align 4, !dbg !248
  store i8* %20, i8** %8, align 4, !dbg !249
  %21 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 1, !dbg !250
  %22 = load i8*, i8** %21, align 4, !dbg !250
  store i8* %22, i8** %9, align 4, !dbg !251
  %23 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 2, !dbg !252
  %24 = load i32, i32* %23, align 4, !dbg !252
  store i32 %24, i32* %3, align 4, !dbg !253
  %25 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 3, !dbg !254
  %26 = load i32, i32* %25, align 4, !dbg !254
  store i32 %26, i32* %4, align 4, !dbg !255
  store i32 1, i32* %5, align 4, !dbg !256
  br label %27, !dbg !257

; <label>:27:                                     ; preds = %51, %34, %14
  %28 = load i32, i32* %5, align 4, !dbg !258
  %29 = icmp eq i32 %28, 1, !dbg !263
  br i1 %29, label %30, label %31, !dbg !264

; <label>:30:                                     ; preds = %27
  store i32 0, i32* %5, align 4, !dbg !265
  call void @vTaskDelay(i32 200), !dbg !267
  br label %31, !dbg !268

; <label>:31:                                     ; preds = %30, %27
  %32 = load i8*, i8** %8, align 4, !dbg !269
  %33 = icmp eq i8* %32, null, !dbg !271
  br i1 %33, label %34, label %35, !dbg !272

; <label>:34:                                     ; preds = %31
  store i32 1, i32* %5, align 4, !dbg !273
  br label %27, !dbg !275, !llvm.loop !276

; <label>:35:                                     ; preds = %31
  %36 = load i8*, i8** %8, align 4, !dbg !277
  %37 = bitcast i32** %7 to i8*, !dbg !278
  %38 = call i32 @xQueueReceive(i8* %36, i8* %37, i32 5), !dbg !279
  store i32 0, i32* %6, align 4, !dbg !280
  br label %39, !dbg !282

; <label>:39:                                     ; preds = %48, %35
  %40 = load i32, i32* %6, align 4, !dbg !283
  %41 = icmp slt i32 %40, 10, !dbg !286
  br i1 %41, label %42, label %51, !dbg !287

; <label>:42:                                     ; preds = %39
  %43 = load i32, i32* %6, align 4, !dbg !288
  %44 = load i32*, i32** %7, align 4, !dbg !290
  %45 = getelementptr inbounds i32, i32* %44, i32 %43, !dbg !290
  %46 = load i32, i32* %45, align 4, !dbg !291
  %47 = mul nsw i32 %46, 2, !dbg !291
  store i32 %47, i32* %45, align 4, !dbg !291
  br label %48, !dbg !292

; <label>:48:                                     ; preds = %42
  %49 = load i32, i32* %6, align 4, !dbg !293
  %50 = add nsw i32 %49, 1, !dbg !293
  store i32 %50, i32* %6, align 4, !dbg !293
  br label %39, !dbg !295, !llvm.loop !296

; <label>:51:                                     ; preds = %39
  %52 = load i8*, i8** %9, align 4, !dbg !298
  %53 = bitcast i32** %7 to i8*, !dbg !298
  %54 = call i32 @xQueueGenericSend(i8* %52, i8* %53, i32 5, i32 0), !dbg !298
  br label %27, !dbg !299, !llvm.loop !276
                                                  ; No predecessors!
  ret void, !dbg !301
}

; Function Attrs: nounwind
define void @QPrintTask(i8*) #0 !dbg !302 !xidane.fname !303 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32*, align 4
  %8 = alloca i8*, align 4
  %9 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !304, metadata !40), !dbg !305
  call void @llvm.dbg.declare(metadata i32* %3, metadata !306, metadata !40), !dbg !307
  call void @llvm.dbg.declare(metadata i32* %4, metadata !308, metadata !40), !dbg !309
  call void @llvm.dbg.declare(metadata i32* %5, metadata !310, metadata !40), !dbg !311
  call void @llvm.dbg.declare(metadata i32* %6, metadata !312, metadata !40), !dbg !313
  call void @llvm.dbg.declare(metadata i32** %7, metadata !314, metadata !40), !dbg !315
  call void @llvm.dbg.declare(metadata i8** %8, metadata !316, metadata !40), !dbg !317
  call void @llvm.dbg.declare(metadata %struct.QueueData* %9, metadata !318, metadata !40), !dbg !319
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.6, i32 0, i32 0)), !dbg !320
  %10 = load i8*, i8** %2, align 4, !dbg !321
  %11 = icmp eq i8* %10, null, !dbg !323
  br i1 %11, label %12, label %13, !dbg !324

; <label>:12:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.7, i32 0, i32 0)), !dbg !325
  call void @vTaskDelete(i8* null), !dbg !327
  br label %13, !dbg !328

; <label>:13:                                     ; preds = %12, %1
  %14 = load i8*, i8** %2, align 4, !dbg !329
  %15 = bitcast i8* %14 to %struct.QueueData*, !dbg !330
  %16 = bitcast %struct.QueueData* %9 to i8*, !dbg !331
  %17 = bitcast %struct.QueueData* %15 to i8*, !dbg !331
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %16, i8* %17, i32 16, i32 4, i1 false), !dbg !331
  %18 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 0, !dbg !332
  %19 = load i8*, i8** %18, align 4, !dbg !332
  store i8* %19, i8** %8, align 4, !dbg !333
  %20 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 2, !dbg !334
  %21 = load i32, i32* %20, align 4, !dbg !334
  store i32 %21, i32* %3, align 4, !dbg !335
  %22 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 3, !dbg !336
  %23 = load i32, i32* %22, align 4, !dbg !336
  store i32 %23, i32* %4, align 4, !dbg !337
  store i32 1, i32* %5, align 4, !dbg !338
  br label %24, !dbg !339

; <label>:24:                                     ; preds = %47, %31, %13
  %25 = load i32, i32* %5, align 4, !dbg !340
  %26 = icmp eq i32 %25, 1, !dbg !345
  br i1 %26, label %27, label %28, !dbg !346

; <label>:27:                                     ; preds = %24
  store i32 0, i32* %5, align 4, !dbg !347
  call void @vTaskDelay(i32 200), !dbg !349
  br label %28, !dbg !350

; <label>:28:                                     ; preds = %27, %24
  %29 = load i8*, i8** %8, align 4, !dbg !351
  %30 = icmp eq i8* %29, null, !dbg !353
  br i1 %30, label %31, label %32, !dbg !354

; <label>:31:                                     ; preds = %28
  store i32 1, i32* %5, align 4, !dbg !355
  br label %24, !dbg !357, !llvm.loop !358

; <label>:32:                                     ; preds = %28
  %33 = load i8*, i8** %8, align 4, !dbg !359
  %34 = bitcast i32** %7 to i8*, !dbg !360
  %35 = call i32 @xQueueReceive(i8* %33, i8* %34, i32 5), !dbg !361
  store i32 0, i32* %6, align 4, !dbg !362
  br label %36, !dbg !364

; <label>:36:                                     ; preds = %44, %32
  %37 = load i32, i32* %6, align 4, !dbg !365
  %38 = icmp slt i32 %37, 10, !dbg !368
  br i1 %38, label %39, label %47, !dbg !369

; <label>:39:                                     ; preds = %36
  %40 = load i32, i32* %6, align 4, !dbg !370
  %41 = load i32*, i32** %7, align 4, !dbg !372
  %42 = getelementptr inbounds i32, i32* %41, i32 %40, !dbg !372
  %43 = load i32, i32* %42, align 4, !dbg !372
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.8, i32 0, i32 0), i32 %43), !dbg !373
  br label %44, !dbg !374

; <label>:44:                                     ; preds = %39
  %45 = load i32, i32* %6, align 4, !dbg !375
  %46 = add nsw i32 %45, 1, !dbg !375
  store i32 %46, i32* %6, align 4, !dbg !375
  br label %36, !dbg !377, !llvm.loop !378

; <label>:47:                                     ; preds = %36
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.9, i32 0, i32 0)), !dbg !380
  %48 = load i32*, i32** %7, align 4, !dbg !381
  %49 = bitcast i32* %48 to i8*, !dbg !381
  call void @vPortFree(i8* %49), !dbg !382
  br label %24, !dbg !383, !llvm.loop !358
                                                  ; No predecessors!
  ret void, !dbg !385
}

declare !xidane.fname !386 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !124 !xidane.ExternC !38 void @vPortFree(i8*) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!26, !27, !28, !29}
!llvm.ident = !{!30}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src/QueueTest.c", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!2 = !{}
!3 = !{!4, !5, !17, !24}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 32, align: 32)
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueData", file: !7, line: 31, baseType: !8)
!7 = !DIFile(filename: "../src/QueueTest.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!8 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "QueueData", file: !7, line: 25, size: 128, align: 32, elements: !9)
!9 = !{!10, !13, !14, !16}
!10 = !DIDerivedType(tag: DW_TAG_member, name: "inputQueue", scope: !8, file: !7, line: 27, baseType: !11, size: 32, align: 32)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueHandle_t", file: !12, line: 47, baseType: !4)
!12 = !DIFile(filename: "/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/queue.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!13 = !DIDerivedType(tag: DW_TAG_member, name: "outputQueue", scope: !8, file: !7, line: 28, baseType: !11, size: 32, align: 32, offset: 32)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "queueLength", scope: !8, file: !7, line: 29, baseType: !15, size: 32, align: 32, offset: 64)
!15 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!16 = !DIDerivedType(tag: DW_TAG_member, name: "blockSize", scope: !8, file: !7, line: 30, baseType: !15, size: 32, align: 32, offset: 96)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "TickType_t", file: !18, line: 62, baseType: !19)
!18 = !DIFile(filename: "/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!19 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !20, line: 32, baseType: !21)
!20 = !DIFile(filename: "/home/timothyduke/Documents/SDK/2018.2/gnu/aarch32/lin/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include/sys/_stdint.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!21 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !22, line: 65, baseType: !23)
!22 = !DIFile(filename: "/home/timothyduke/Documents/SDK/2018.2/gnu/aarch32/lin/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include/machine/_default_types.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!23 = !DIBasicType(name: "unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!24 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !18, line: 59, baseType: !25)
!25 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!26 = !{i32 2, !"Dwarf Version", i32 4}
!27 = !{i32 2, !"Debug Info Version", i32 3}
!28 = !{i32 1, !"wchar_size", i32 4}
!29 = !{i32 1, !"min_enum_size", i32 4}
!30 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!31 = distinct !DISubprogram(name: "QStartTask", scope: !32, file: !32, line: 32, type: !33, isLocal: false, isDefinition: true, scopeLine: 33, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!32 = !DIFile(filename: "/home/timothyduke/workspace/SeniorDesign/src/QueueTest.c", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!33 = !DISubroutineType(types: !34)
!34 = !{null, !4}
!35 = !{!"QStartTask"}
!36 = !{!"void.void *.1"}
!37 = !{!"../src/QueueTest.h"}
!38 = !{!"t"}
!39 = !DILocalVariable(name: "parameters", arg: 1, scope: !31, file: !32, line: 32, type: !4)
!40 = !DIExpression()
!41 = !DILocation(line: 32, column: 23, scope: !31)
!42 = !DILocalVariable(name: "queueLength", scope: !31, file: !32, line: 34, type: !15)
!43 = !DILocation(line: 34, column: 6, scope: !31)
!44 = !DILocalVariable(name: "blockSize", scope: !31, file: !32, line: 34, type: !15)
!45 = !DILocation(line: 34, column: 19, scope: !31)
!46 = !DILocalVariable(name: "DelayFlag", scope: !31, file: !32, line: 34, type: !15)
!47 = !DILocation(line: 34, column: 30, scope: !31)
!48 = !DILocalVariable(name: "i", scope: !31, file: !32, line: 34, type: !15)
!49 = !DILocation(line: 34, column: 41, scope: !31)
!50 = !DILocalVariable(name: "array", scope: !31, file: !32, line: 37, type: !51)
!51 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 32, align: 32)
!52 = !DILocation(line: 37, column: 7, scope: !31)
!53 = !DILocalVariable(name: "outputQueue", scope: !31, file: !32, line: 39, type: !11)
!54 = !DILocation(line: 39, column: 16, scope: !31)
!55 = !DILocalVariable(name: "myQueueData", scope: !31, file: !32, line: 41, type: !6)
!56 = !DILocation(line: 41, column: 12, scope: !31)
!57 = !DILocation(line: 43, column: 2, scope: !31)
!58 = !DILocation(line: 45, column: 6, scope: !59)
!59 = distinct !DILexicalBlock(scope: !31, file: !32, line: 45, column: 6)
!60 = !DILocation(line: 45, column: 17, scope: !59)
!61 = !DILocation(line: 45, column: 6, scope: !31)
!62 = !DILocation(line: 47, column: 3, scope: !63)
!63 = distinct !DILexicalBlock(scope: !59, file: !32, line: 46, column: 2)
!64 = !DILocation(line: 48, column: 3, scope: !63)
!65 = !DILocation(line: 49, column: 2, scope: !63)
!66 = !DILocation(line: 51, column: 32, scope: !31)
!67 = !DILocation(line: 51, column: 18, scope: !31)
!68 = !DILocation(line: 51, column: 16, scope: !31)
!69 = !DILocation(line: 53, column: 28, scope: !31)
!70 = !DILocation(line: 53, column: 14, scope: !31)
!71 = !DILocation(line: 54, column: 28, scope: !31)
!72 = !DILocation(line: 54, column: 14, scope: !31)
!73 = !DILocation(line: 55, column: 26, scope: !31)
!74 = !DILocation(line: 55, column: 12, scope: !31)
!75 = !DILocation(line: 58, column: 12, scope: !31)
!76 = !DILocation(line: 60, column: 2, scope: !31)
!77 = !DILocation(line: 63, column: 7, scope: !78)
!78 = distinct !DILexicalBlock(scope: !79, file: !32, line: 63, column: 7)
!79 = distinct !DILexicalBlock(scope: !80, file: !32, line: 61, column: 2)
!80 = distinct !DILexicalBlock(scope: !81, file: !32, line: 60, column: 2)
!81 = distinct !DILexicalBlock(scope: !31, file: !32, line: 60, column: 2)
!82 = !DILocation(line: 63, column: 17, scope: !78)
!83 = !DILocation(line: 63, column: 7, scope: !79)
!84 = !DILocation(line: 66, column: 14, scope: !85)
!85 = distinct !DILexicalBlock(scope: !78, file: !32, line: 64, column: 3)
!86 = !DILocation(line: 69, column: 4, scope: !85)
!87 = !DILocation(line: 70, column: 3, scope: !85)
!88 = !DILocation(line: 83, column: 11, scope: !79)
!89 = !DILocation(line: 83, column: 9, scope: !79)
!90 = !DILocation(line: 85, column: 10, scope: !91)
!91 = distinct !DILexicalBlock(scope: !79, file: !32, line: 85, column: 3)
!92 = !DILocation(line: 85, column: 8, scope: !91)
!93 = !DILocation(line: 85, column: 15, scope: !94)
!94 = !DILexicalBlockFile(scope: !95, file: !32, discriminator: 1)
!95 = distinct !DILexicalBlock(scope: !91, file: !32, line: 85, column: 3)
!96 = !DILocation(line: 85, column: 17, scope: !94)
!97 = !DILocation(line: 85, column: 3, scope: !94)
!98 = !DILocation(line: 87, column: 15, scope: !99)
!99 = distinct !DILexicalBlock(scope: !95, file: !32, line: 86, column: 3)
!100 = !DILocation(line: 87, column: 10, scope: !99)
!101 = !DILocation(line: 87, column: 4, scope: !99)
!102 = !DILocation(line: 87, column: 13, scope: !99)
!103 = !DILocation(line: 88, column: 3, scope: !99)
!104 = !DILocation(line: 85, column: 24, scope: !105)
!105 = !DILexicalBlockFile(scope: !95, file: !32, discriminator: 2)
!106 = !DILocation(line: 85, column: 3, scope: !105)
!107 = distinct !{!107, !108}
!108 = !DILocation(line: 85, column: 3, scope: !79)
!109 = !DILocation(line: 90, column: 3, scope: !79)
!110 = !DILocation(line: 60, column: 2, scope: !111)
!111 = !DILexicalBlockFile(scope: !80, file: !32, discriminator: 1)
!112 = distinct !{!112, !76}
!113 = !DILocation(line: 102, column: 1, scope: !31)
!114 = !{!"xil_printf"}
!115 = !{!"void.const char8 *.1"}
!116 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!117 = !{!"vTaskDelete"}
!118 = !{!"void.TaskHandle_t.1"}
!119 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/task.h"}
!120 = !{!"vTaskDelay"}
!121 = !{!"void.const TickType_t.0"}
!122 = !{!"pvPortMalloc"}
!123 = !{!"void .size_t.0"}
!124 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portable.h"}
!125 = !{!"xQueueGenericSend"}
!126 = !{!"BaseType_t.QueueHandle_t.1.const void *const.1.TickType_t.0.const BaseType_t.0"}
!127 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/queue.h"}
!128 = distinct !DISubprogram(name: "QAddTask", scope: !32, file: !32, line: 112, type: !33, isLocal: false, isDefinition: true, scopeLine: 113, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!129 = !{!"QAddTask"}
!130 = !DILocalVariable(name: "parameters", arg: 1, scope: !128, file: !32, line: 112, type: !4)
!131 = !DILocation(line: 112, column: 21, scope: !128)
!132 = !DILocalVariable(name: "queueLength", scope: !128, file: !32, line: 114, type: !15)
!133 = !DILocation(line: 114, column: 6, scope: !128)
!134 = !DILocalVariable(name: "blockSize", scope: !128, file: !32, line: 114, type: !15)
!135 = !DILocation(line: 114, column: 19, scope: !128)
!136 = !DILocalVariable(name: "DelayFlag", scope: !128, file: !32, line: 114, type: !15)
!137 = !DILocation(line: 114, column: 30, scope: !128)
!138 = !DILocalVariable(name: "i", scope: !128, file: !32, line: 114, type: !15)
!139 = !DILocation(line: 114, column: 41, scope: !128)
!140 = !DILocalVariable(name: "array", scope: !128, file: !32, line: 116, type: !51)
!141 = !DILocation(line: 116, column: 8, scope: !128)
!142 = !DILocalVariable(name: "inputQueue", scope: !128, file: !32, line: 118, type: !11)
!143 = !DILocation(line: 118, column: 16, scope: !128)
!144 = !DILocalVariable(name: "outputQueue", scope: !128, file: !32, line: 119, type: !11)
!145 = !DILocation(line: 119, column: 16, scope: !128)
!146 = !DILocation(line: 121, column: 2, scope: !128)
!147 = !DILocalVariable(name: "myQueueData", scope: !128, file: !32, line: 123, type: !6)
!148 = !DILocation(line: 123, column: 12, scope: !128)
!149 = !DILocation(line: 125, column: 6, scope: !150)
!150 = distinct !DILexicalBlock(scope: !128, file: !32, line: 125, column: 6)
!151 = !DILocation(line: 125, column: 17, scope: !150)
!152 = !DILocation(line: 125, column: 6, scope: !128)
!153 = !DILocation(line: 127, column: 3, scope: !154)
!154 = distinct !DILexicalBlock(scope: !150, file: !32, line: 126, column: 2)
!155 = !DILocation(line: 128, column: 3, scope: !154)
!156 = !DILocation(line: 129, column: 2, scope: !154)
!157 = !DILocation(line: 131, column: 32, scope: !128)
!158 = !DILocation(line: 131, column: 18, scope: !128)
!159 = !DILocation(line: 131, column: 16, scope: !128)
!160 = !DILocation(line: 133, column: 27, scope: !128)
!161 = !DILocation(line: 133, column: 13, scope: !128)
!162 = !DILocation(line: 134, column: 28, scope: !128)
!163 = !DILocation(line: 134, column: 14, scope: !128)
!164 = !DILocation(line: 135, column: 28, scope: !128)
!165 = !DILocation(line: 135, column: 14, scope: !128)
!166 = !DILocation(line: 136, column: 26, scope: !128)
!167 = !DILocation(line: 136, column: 12, scope: !128)
!168 = !DILocation(line: 139, column: 12, scope: !128)
!169 = !DILocation(line: 141, column: 2, scope: !128)
!170 = !DILocation(line: 144, column: 6, scope: !171)
!171 = distinct !DILexicalBlock(scope: !172, file: !32, line: 144, column: 6)
!172 = distinct !DILexicalBlock(scope: !173, file: !32, line: 142, column: 2)
!173 = distinct !DILexicalBlock(scope: !174, file: !32, line: 141, column: 2)
!174 = distinct !DILexicalBlock(scope: !128, file: !32, line: 141, column: 2)
!175 = !DILocation(line: 144, column: 16, scope: !171)
!176 = !DILocation(line: 144, column: 6, scope: !172)
!177 = !DILocation(line: 147, column: 14, scope: !178)
!178 = distinct !DILexicalBlock(scope: !171, file: !32, line: 145, column: 3)
!179 = !DILocation(line: 149, column: 4, scope: !178)
!180 = !DILocation(line: 150, column: 3, scope: !178)
!181 = !DILocation(line: 153, column: 7, scope: !182)
!182 = distinct !DILexicalBlock(scope: !172, file: !32, line: 153, column: 7)
!183 = !DILocation(line: 153, column: 18, scope: !182)
!184 = !DILocation(line: 153, column: 7, scope: !172)
!185 = !DILocation(line: 156, column: 14, scope: !186)
!186 = distinct !DILexicalBlock(scope: !182, file: !32, line: 154, column: 3)
!187 = !DILocation(line: 159, column: 4, scope: !186)
!188 = distinct !{!188, !169}
!189 = !DILocation(line: 163, column: 18, scope: !172)
!190 = !DILocation(line: 163, column: 30, scope: !172)
!191 = !DILocation(line: 163, column: 3, scope: !172)
!192 = !DILocation(line: 165, column: 10, scope: !193)
!193 = distinct !DILexicalBlock(scope: !172, file: !32, line: 165, column: 3)
!194 = !DILocation(line: 165, column: 8, scope: !193)
!195 = !DILocation(line: 165, column: 15, scope: !196)
!196 = !DILexicalBlockFile(scope: !197, file: !32, discriminator: 1)
!197 = distinct !DILexicalBlock(scope: !193, file: !32, line: 165, column: 3)
!198 = !DILocation(line: 165, column: 17, scope: !196)
!199 = !DILocation(line: 165, column: 3, scope: !196)
!200 = !DILocation(line: 167, column: 11, scope: !201)
!201 = distinct !DILexicalBlock(scope: !197, file: !32, line: 166, column: 3)
!202 = !DILocation(line: 167, column: 4, scope: !201)
!203 = !DILocation(line: 167, column: 14, scope: !201)
!204 = !DILocation(line: 168, column: 3, scope: !201)
!205 = !DILocation(line: 165, column: 24, scope: !206)
!206 = !DILexicalBlockFile(scope: !197, file: !32, discriminator: 2)
!207 = !DILocation(line: 165, column: 3, scope: !206)
!208 = distinct !{!208, !209}
!209 = !DILocation(line: 165, column: 3, scope: !172)
!210 = !DILocation(line: 170, column: 3, scope: !172)
!211 = !DILocation(line: 141, column: 2, scope: !212)
!212 = !DILexicalBlockFile(scope: !173, file: !32, discriminator: 1)
!213 = !DILocation(line: 181, column: 1, scope: !128)
!214 = !{!"xQueueReceive"}
!215 = !{!"BaseType_t.QueueHandle_t.1.void *const.1.TickType_t.0"}
!216 = distinct !DISubprogram(name: "QMultTask", scope: !32, file: !32, line: 191, type: !33, isLocal: false, isDefinition: true, scopeLine: 192, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!217 = !{!"QMultTask"}
!218 = !DILocalVariable(name: "parameters", arg: 1, scope: !216, file: !32, line: 191, type: !4)
!219 = !DILocation(line: 191, column: 22, scope: !216)
!220 = !DILocalVariable(name: "queueLength", scope: !216, file: !32, line: 193, type: !15)
!221 = !DILocation(line: 193, column: 6, scope: !216)
!222 = !DILocalVariable(name: "blockSize", scope: !216, file: !32, line: 193, type: !15)
!223 = !DILocation(line: 193, column: 19, scope: !216)
!224 = !DILocalVariable(name: "DelayFlag", scope: !216, file: !32, line: 193, type: !15)
!225 = !DILocation(line: 193, column: 30, scope: !216)
!226 = !DILocalVariable(name: "i", scope: !216, file: !32, line: 193, type: !15)
!227 = !DILocation(line: 193, column: 41, scope: !216)
!228 = !DILocalVariable(name: "array", scope: !216, file: !32, line: 195, type: !51)
!229 = !DILocation(line: 195, column: 8, scope: !216)
!230 = !DILocalVariable(name: "inputQueue", scope: !216, file: !32, line: 197, type: !11)
!231 = !DILocation(line: 197, column: 16, scope: !216)
!232 = !DILocalVariable(name: "outputQueue", scope: !216, file: !32, line: 198, type: !11)
!233 = !DILocation(line: 198, column: 16, scope: !216)
!234 = !DILocation(line: 200, column: 2, scope: !216)
!235 = !DILocalVariable(name: "myQueueData", scope: !216, file: !32, line: 202, type: !6)
!236 = !DILocation(line: 202, column: 12, scope: !216)
!237 = !DILocation(line: 204, column: 6, scope: !238)
!238 = distinct !DILexicalBlock(scope: !216, file: !32, line: 204, column: 6)
!239 = !DILocation(line: 204, column: 17, scope: !238)
!240 = !DILocation(line: 204, column: 6, scope: !216)
!241 = !DILocation(line: 206, column: 3, scope: !242)
!242 = distinct !DILexicalBlock(scope: !238, file: !32, line: 205, column: 2)
!243 = !DILocation(line: 207, column: 3, scope: !242)
!244 = !DILocation(line: 208, column: 2, scope: !242)
!245 = !DILocation(line: 210, column: 32, scope: !216)
!246 = !DILocation(line: 210, column: 18, scope: !216)
!247 = !DILocation(line: 210, column: 16, scope: !216)
!248 = !DILocation(line: 212, column: 27, scope: !216)
!249 = !DILocation(line: 212, column: 13, scope: !216)
!250 = !DILocation(line: 213, column: 28, scope: !216)
!251 = !DILocation(line: 213, column: 14, scope: !216)
!252 = !DILocation(line: 214, column: 28, scope: !216)
!253 = !DILocation(line: 214, column: 14, scope: !216)
!254 = !DILocation(line: 215, column: 26, scope: !216)
!255 = !DILocation(line: 215, column: 12, scope: !216)
!256 = !DILocation(line: 218, column: 12, scope: !216)
!257 = !DILocation(line: 220, column: 2, scope: !216)
!258 = !DILocation(line: 223, column: 6, scope: !259)
!259 = distinct !DILexicalBlock(scope: !260, file: !32, line: 223, column: 6)
!260 = distinct !DILexicalBlock(scope: !261, file: !32, line: 221, column: 2)
!261 = distinct !DILexicalBlock(scope: !262, file: !32, line: 220, column: 2)
!262 = distinct !DILexicalBlock(scope: !216, file: !32, line: 220, column: 2)
!263 = !DILocation(line: 223, column: 16, scope: !259)
!264 = !DILocation(line: 223, column: 6, scope: !260)
!265 = !DILocation(line: 226, column: 14, scope: !266)
!266 = distinct !DILexicalBlock(scope: !259, file: !32, line: 224, column: 3)
!267 = !DILocation(line: 228, column: 4, scope: !266)
!268 = !DILocation(line: 229, column: 3, scope: !266)
!269 = !DILocation(line: 232, column: 7, scope: !270)
!270 = distinct !DILexicalBlock(scope: !260, file: !32, line: 232, column: 7)
!271 = !DILocation(line: 232, column: 18, scope: !270)
!272 = !DILocation(line: 232, column: 7, scope: !260)
!273 = !DILocation(line: 235, column: 14, scope: !274)
!274 = distinct !DILexicalBlock(scope: !270, file: !32, line: 233, column: 3)
!275 = !DILocation(line: 238, column: 4, scope: !274)
!276 = distinct !{!276, !257}
!277 = !DILocation(line: 242, column: 18, scope: !260)
!278 = !DILocation(line: 242, column: 30, scope: !260)
!279 = !DILocation(line: 242, column: 3, scope: !260)
!280 = !DILocation(line: 244, column: 10, scope: !281)
!281 = distinct !DILexicalBlock(scope: !260, file: !32, line: 244, column: 3)
!282 = !DILocation(line: 244, column: 8, scope: !281)
!283 = !DILocation(line: 244, column: 15, scope: !284)
!284 = !DILexicalBlockFile(scope: !285, file: !32, discriminator: 1)
!285 = distinct !DILexicalBlock(scope: !281, file: !32, line: 244, column: 3)
!286 = !DILocation(line: 244, column: 17, scope: !284)
!287 = !DILocation(line: 244, column: 3, scope: !284)
!288 = !DILocation(line: 246, column: 11, scope: !289)
!289 = distinct !DILexicalBlock(scope: !285, file: !32, line: 245, column: 3)
!290 = !DILocation(line: 246, column: 4, scope: !289)
!291 = !DILocation(line: 246, column: 14, scope: !289)
!292 = !DILocation(line: 247, column: 3, scope: !289)
!293 = !DILocation(line: 244, column: 24, scope: !294)
!294 = !DILexicalBlockFile(scope: !285, file: !32, discriminator: 2)
!295 = !DILocation(line: 244, column: 3, scope: !294)
!296 = distinct !{!296, !297}
!297 = !DILocation(line: 244, column: 3, scope: !260)
!298 = !DILocation(line: 249, column: 3, scope: !260)
!299 = !DILocation(line: 220, column: 2, scope: !300)
!300 = !DILexicalBlockFile(scope: !261, file: !32, discriminator: 1)
!301 = !DILocation(line: 260, column: 1, scope: !216)
!302 = distinct !DISubprogram(name: "QPrintTask", scope: !32, file: !32, line: 270, type: !33, isLocal: false, isDefinition: true, scopeLine: 271, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!303 = !{!"QPrintTask"}
!304 = !DILocalVariable(name: "parameters", arg: 1, scope: !302, file: !32, line: 270, type: !4)
!305 = !DILocation(line: 270, column: 23, scope: !302)
!306 = !DILocalVariable(name: "queueLength", scope: !302, file: !32, line: 272, type: !15)
!307 = !DILocation(line: 272, column: 6, scope: !302)
!308 = !DILocalVariable(name: "blockSize", scope: !302, file: !32, line: 272, type: !15)
!309 = !DILocation(line: 272, column: 19, scope: !302)
!310 = !DILocalVariable(name: "DelayFlag", scope: !302, file: !32, line: 272, type: !15)
!311 = !DILocation(line: 272, column: 30, scope: !302)
!312 = !DILocalVariable(name: "i", scope: !302, file: !32, line: 272, type: !15)
!313 = !DILocation(line: 272, column: 41, scope: !302)
!314 = !DILocalVariable(name: "array", scope: !302, file: !32, line: 274, type: !51)
!315 = !DILocation(line: 274, column: 8, scope: !302)
!316 = !DILocalVariable(name: "inputQueue", scope: !302, file: !32, line: 276, type: !11)
!317 = !DILocation(line: 276, column: 16, scope: !302)
!318 = !DILocalVariable(name: "myQueueData", scope: !302, file: !32, line: 278, type: !6)
!319 = !DILocation(line: 278, column: 12, scope: !302)
!320 = !DILocation(line: 280, column: 2, scope: !302)
!321 = !DILocation(line: 282, column: 6, scope: !322)
!322 = distinct !DILexicalBlock(scope: !302, file: !32, line: 282, column: 6)
!323 = !DILocation(line: 282, column: 17, scope: !322)
!324 = !DILocation(line: 282, column: 6, scope: !302)
!325 = !DILocation(line: 284, column: 3, scope: !326)
!326 = distinct !DILexicalBlock(scope: !322, file: !32, line: 283, column: 2)
!327 = !DILocation(line: 285, column: 3, scope: !326)
!328 = !DILocation(line: 286, column: 2, scope: !326)
!329 = !DILocation(line: 288, column: 32, scope: !302)
!330 = !DILocation(line: 288, column: 18, scope: !302)
!331 = !DILocation(line: 288, column: 16, scope: !302)
!332 = !DILocation(line: 290, column: 27, scope: !302)
!333 = !DILocation(line: 290, column: 13, scope: !302)
!334 = !DILocation(line: 291, column: 28, scope: !302)
!335 = !DILocation(line: 291, column: 14, scope: !302)
!336 = !DILocation(line: 292, column: 26, scope: !302)
!337 = !DILocation(line: 292, column: 12, scope: !302)
!338 = !DILocation(line: 295, column: 12, scope: !302)
!339 = !DILocation(line: 297, column: 2, scope: !302)
!340 = !DILocation(line: 300, column: 6, scope: !341)
!341 = distinct !DILexicalBlock(scope: !342, file: !32, line: 300, column: 6)
!342 = distinct !DILexicalBlock(scope: !343, file: !32, line: 298, column: 2)
!343 = distinct !DILexicalBlock(scope: !344, file: !32, line: 297, column: 2)
!344 = distinct !DILexicalBlock(scope: !302, file: !32, line: 297, column: 2)
!345 = !DILocation(line: 300, column: 16, scope: !341)
!346 = !DILocation(line: 300, column: 6, scope: !342)
!347 = !DILocation(line: 303, column: 14, scope: !348)
!348 = distinct !DILexicalBlock(scope: !341, file: !32, line: 301, column: 3)
!349 = !DILocation(line: 305, column: 4, scope: !348)
!350 = !DILocation(line: 306, column: 3, scope: !348)
!351 = !DILocation(line: 309, column: 7, scope: !352)
!352 = distinct !DILexicalBlock(scope: !342, file: !32, line: 309, column: 7)
!353 = !DILocation(line: 309, column: 18, scope: !352)
!354 = !DILocation(line: 309, column: 7, scope: !342)
!355 = !DILocation(line: 312, column: 14, scope: !356)
!356 = distinct !DILexicalBlock(scope: !352, file: !32, line: 310, column: 3)
!357 = !DILocation(line: 315, column: 4, scope: !356)
!358 = distinct !{!358, !339}
!359 = !DILocation(line: 319, column: 18, scope: !342)
!360 = !DILocation(line: 319, column: 30, scope: !342)
!361 = !DILocation(line: 319, column: 3, scope: !342)
!362 = !DILocation(line: 321, column: 10, scope: !363)
!363 = distinct !DILexicalBlock(scope: !342, file: !32, line: 321, column: 3)
!364 = !DILocation(line: 321, column: 8, scope: !363)
!365 = !DILocation(line: 321, column: 15, scope: !366)
!366 = !DILexicalBlockFile(scope: !367, file: !32, discriminator: 1)
!367 = distinct !DILexicalBlock(scope: !363, file: !32, line: 321, column: 3)
!368 = !DILocation(line: 321, column: 17, scope: !366)
!369 = !DILocation(line: 321, column: 3, scope: !366)
!370 = !DILocation(line: 323, column: 29, scope: !371)
!371 = distinct !DILexicalBlock(scope: !367, file: !32, line: 322, column: 3)
!372 = !DILocation(line: 323, column: 23, scope: !371)
!373 = !DILocation(line: 323, column: 4, scope: !371)
!374 = !DILocation(line: 324, column: 3, scope: !371)
!375 = !DILocation(line: 321, column: 24, scope: !376)
!376 = !DILexicalBlockFile(scope: !367, file: !32, discriminator: 2)
!377 = !DILocation(line: 321, column: 3, scope: !376)
!378 = distinct !{!378, !379}
!379 = !DILocation(line: 321, column: 3, scope: !342)
!380 = !DILocation(line: 325, column: 3, scope: !342)
!381 = !DILocation(line: 327, column: 13, scope: !342)
!382 = !DILocation(line: 327, column: 3, scope: !342)
!383 = !DILocation(line: 297, column: 2, scope: !384)
!384 = !DILexicalBlockFile(scope: !343, file: !32, discriminator: 1)
!385 = !DILocation(line: 338, column: 1, scope: !302)
!386 = !{!"vPortFree"}
