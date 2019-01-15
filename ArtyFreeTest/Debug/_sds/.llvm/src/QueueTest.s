; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.QueueData = type { i8*, i8*, i32, i32 }

@.str = private unnamed_addr constant [5 x i8] c"in_1\00", align 1
@.str.1 = private unnamed_addr constant [42 x i8] c"no parameters sent to QStartTask()\0Aabort\0A\00", align 1
@.str.2 = private unnamed_addr constant [60 x i8] c"C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c\00", align 1
@.str.3 = private unnamed_addr constant [5 x i8] c"in_2\00", align 1
@.str.4 = private unnamed_addr constant [40 x i8] c"no parameters sent to QAddTask()\0Aabort\0A\00", align 1
@.str.5 = private unnamed_addr constant [5 x i8] c"in_3\00", align 1
@.str.6 = private unnamed_addr constant [41 x i8] c"no parameters sent to QMultTask()\0Aabort\0A\00", align 1
@.str.7 = private unnamed_addr constant [5 x i8] c"in_4\00", align 1
@.str.8 = private unnamed_addr constant [42 x i8] c"no parameters sent to QPrintTask()\0Aabort\0A\00", align 1
@.str.9 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str.10 = private unnamed_addr constant [2 x i8] c"\0A\00", align 1

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

; <label>:24:                                     ; preds = %46, %13
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
  %44 = icmp eq i8* %43, null, !dbg !109
  br i1 %44, label %45, label %46, !dbg !111

; <label>:45:                                     ; preds = %42
  call void @vApplicationAssert(i8* getelementptr inbounds ([60 x i8], [60 x i8]* @.str.2, i32 0, i32 0), i32 90), !dbg !112
  br label %46, !dbg !112

; <label>:46:                                     ; preds = %45, %42
  %47 = load i8*, i8** %8, align 4, !dbg !114
  %48 = bitcast i32** %7 to i8*, !dbg !114
  %49 = call i32 @xQueueGenericSend(i8* %47, i8* %48, i32 0, i32 0), !dbg !114
  br label %24, !dbg !115, !llvm.loop !117
                                                  ; No predecessors!
  ret void, !dbg !118
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !119 !xidane.function_declaration_type !120 !xidane.function_declaration_filename !121 !xidane.ExternC !38 void @xil_printf(i8*, ...) #2

declare !xidane.fname !122 !xidane.function_declaration_type !123 !xidane.function_declaration_filename !124 !xidane.ExternC !38 void @vTaskDelete(i8*) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #3

declare !xidane.fname !125 !xidane.function_declaration_type !126 !xidane.function_declaration_filename !124 !xidane.ExternC !38 void @vTaskDelay(i32) #2

declare !xidane.fname !127 !xidane.function_declaration_type !128 !xidane.function_declaration_filename !129 !xidane.ExternC !38 i8* @pvPortMalloc(i32) #2

declare !xidane.fname !130 !xidane.function_declaration_type !131 !xidane.function_declaration_filename !132 !xidane.ExternC !38 void @vApplicationAssert(i8*, i32) #2

declare !xidane.fname !133 !xidane.function_declaration_type !134 !xidane.function_declaration_filename !135 !xidane.ExternC !38 i32 @xQueueGenericSend(i8*, i8*, i32, i32) #2

; Function Attrs: nounwind
define void @QAddTask(i8*) #0 !dbg !136 !xidane.fname !137 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
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
  call void @llvm.dbg.declare(metadata i8** %2, metadata !138, metadata !40), !dbg !139
  call void @llvm.dbg.declare(metadata i32* %3, metadata !140, metadata !40), !dbg !141
  call void @llvm.dbg.declare(metadata i32* %4, metadata !142, metadata !40), !dbg !143
  call void @llvm.dbg.declare(metadata i32* %5, metadata !144, metadata !40), !dbg !145
  call void @llvm.dbg.declare(metadata i32* %6, metadata !146, metadata !40), !dbg !147
  call void @llvm.dbg.declare(metadata i32** %7, metadata !148, metadata !40), !dbg !149
  call void @llvm.dbg.declare(metadata i8** %8, metadata !150, metadata !40), !dbg !151
  call void @llvm.dbg.declare(metadata i8** %9, metadata !152, metadata !40), !dbg !153
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.3, i32 0, i32 0)), !dbg !154
  call void @llvm.dbg.declare(metadata %struct.QueueData* %10, metadata !155, metadata !40), !dbg !156
  %11 = load i8*, i8** %2, align 4, !dbg !157
  %12 = icmp eq i8* %11, null, !dbg !159
  br i1 %12, label %13, label %14, !dbg !160

; <label>:13:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([40 x i8], [40 x i8]* @.str.4, i32 0, i32 0)), !dbg !161
  call void @vTaskDelete(i8* null), !dbg !163
  br label %14, !dbg !164

; <label>:14:                                     ; preds = %13, %1
  %15 = load i8*, i8** %2, align 4, !dbg !165
  %16 = bitcast i8* %15 to %struct.QueueData*, !dbg !166
  %17 = bitcast %struct.QueueData* %10 to i8*, !dbg !167
  %18 = bitcast %struct.QueueData* %16 to i8*, !dbg !167
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %17, i8* %18, i32 16, i32 4, i1 false), !dbg !167
  %19 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 0, !dbg !168
  %20 = load i8*, i8** %19, align 4, !dbg !168
  store i8* %20, i8** %8, align 4, !dbg !169
  %21 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 1, !dbg !170
  %22 = load i8*, i8** %21, align 4, !dbg !170
  store i8* %22, i8** %9, align 4, !dbg !171
  %23 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 2, !dbg !172
  %24 = load i32, i32* %23, align 4, !dbg !172
  store i32 %24, i32* %3, align 4, !dbg !173
  %25 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 3, !dbg !174
  %26 = load i32, i32* %25, align 4, !dbg !174
  store i32 %26, i32* %4, align 4, !dbg !175
  store i32 1, i32* %5, align 4, !dbg !176
  br label %27, !dbg !177

; <label>:27:                                     ; preds = %51, %34, %14
  %28 = load i32, i32* %5, align 4, !dbg !178
  %29 = icmp eq i32 %28, 1, !dbg !183
  br i1 %29, label %30, label %31, !dbg !184

; <label>:30:                                     ; preds = %27
  store i32 0, i32* %5, align 4, !dbg !185
  call void @vTaskDelay(i32 200), !dbg !187
  br label %31, !dbg !188

; <label>:31:                                     ; preds = %30, %27
  %32 = load i8*, i8** %8, align 4, !dbg !189
  %33 = icmp eq i8* %32, null, !dbg !191
  br i1 %33, label %34, label %35, !dbg !192

; <label>:34:                                     ; preds = %31
  store i32 1, i32* %5, align 4, !dbg !193
  br label %27, !dbg !195, !llvm.loop !196

; <label>:35:                                     ; preds = %31
  %36 = load i8*, i8** %8, align 4, !dbg !197
  %37 = bitcast i32** %7 to i8*, !dbg !198
  %38 = call i32 @xQueueReceive(i8* %36, i8* %37, i32 5), !dbg !199
  store i32 0, i32* %6, align 4, !dbg !200
  br label %39, !dbg !202

; <label>:39:                                     ; preds = %48, %35
  %40 = load i32, i32* %6, align 4, !dbg !203
  %41 = icmp slt i32 %40, 10, !dbg !206
  br i1 %41, label %42, label %51, !dbg !207

; <label>:42:                                     ; preds = %39
  %43 = load i32, i32* %6, align 4, !dbg !208
  %44 = load i32*, i32** %7, align 4, !dbg !210
  %45 = getelementptr inbounds i32, i32* %44, i32 %43, !dbg !210
  %46 = load i32, i32* %45, align 4, !dbg !211
  %47 = add nsw i32 %46, 1, !dbg !211
  store i32 %47, i32* %45, align 4, !dbg !211
  br label %48, !dbg !212

; <label>:48:                                     ; preds = %42
  %49 = load i32, i32* %6, align 4, !dbg !213
  %50 = add nsw i32 %49, 1, !dbg !213
  store i32 %50, i32* %6, align 4, !dbg !213
  br label %39, !dbg !215, !llvm.loop !216

; <label>:51:                                     ; preds = %39
  %52 = load i8*, i8** %9, align 4, !dbg !218
  %53 = bitcast i32** %7 to i8*, !dbg !218
  %54 = call i32 @xQueueGenericSend(i8* %52, i8* %53, i32 5, i32 0), !dbg !218
  br label %27, !dbg !219, !llvm.loop !196
                                                  ; No predecessors!
  ret void, !dbg !221
}

declare !xidane.fname !222 !xidane.function_declaration_type !223 !xidane.function_declaration_filename !135 !xidane.ExternC !38 i32 @xQueueReceive(i8*, i8*, i32) #2

; Function Attrs: nounwind
define void @QMultTask(i8*) #0 !dbg !224 !xidane.fname !225 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
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
  call void @llvm.dbg.declare(metadata i8** %2, metadata !226, metadata !40), !dbg !227
  call void @llvm.dbg.declare(metadata i32* %3, metadata !228, metadata !40), !dbg !229
  call void @llvm.dbg.declare(metadata i32* %4, metadata !230, metadata !40), !dbg !231
  call void @llvm.dbg.declare(metadata i32* %5, metadata !232, metadata !40), !dbg !233
  call void @llvm.dbg.declare(metadata i32* %6, metadata !234, metadata !40), !dbg !235
  call void @llvm.dbg.declare(metadata i32** %7, metadata !236, metadata !40), !dbg !237
  call void @llvm.dbg.declare(metadata i8** %8, metadata !238, metadata !40), !dbg !239
  call void @llvm.dbg.declare(metadata i8** %9, metadata !240, metadata !40), !dbg !241
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.5, i32 0, i32 0)), !dbg !242
  call void @llvm.dbg.declare(metadata %struct.QueueData* %10, metadata !243, metadata !40), !dbg !244
  %11 = load i8*, i8** %2, align 4, !dbg !245
  %12 = icmp eq i8* %11, null, !dbg !247
  br i1 %12, label %13, label %14, !dbg !248

; <label>:13:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([41 x i8], [41 x i8]* @.str.6, i32 0, i32 0)), !dbg !249
  call void @vTaskDelete(i8* null), !dbg !251
  br label %14, !dbg !252

; <label>:14:                                     ; preds = %13, %1
  %15 = load i8*, i8** %2, align 4, !dbg !253
  %16 = bitcast i8* %15 to %struct.QueueData*, !dbg !254
  %17 = bitcast %struct.QueueData* %10 to i8*, !dbg !255
  %18 = bitcast %struct.QueueData* %16 to i8*, !dbg !255
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %17, i8* %18, i32 16, i32 4, i1 false), !dbg !255
  %19 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 0, !dbg !256
  %20 = load i8*, i8** %19, align 4, !dbg !256
  store i8* %20, i8** %8, align 4, !dbg !257
  %21 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 1, !dbg !258
  %22 = load i8*, i8** %21, align 4, !dbg !258
  store i8* %22, i8** %9, align 4, !dbg !259
  %23 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 2, !dbg !260
  %24 = load i32, i32* %23, align 4, !dbg !260
  store i32 %24, i32* %3, align 4, !dbg !261
  %25 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %10, i32 0, i32 3, !dbg !262
  %26 = load i32, i32* %25, align 4, !dbg !262
  store i32 %26, i32* %4, align 4, !dbg !263
  store i32 1, i32* %5, align 4, !dbg !264
  br label %27, !dbg !265

; <label>:27:                                     ; preds = %51, %34, %14
  %28 = load i32, i32* %5, align 4, !dbg !266
  %29 = icmp eq i32 %28, 1, !dbg !271
  br i1 %29, label %30, label %31, !dbg !272

; <label>:30:                                     ; preds = %27
  store i32 0, i32* %5, align 4, !dbg !273
  call void @vTaskDelay(i32 200), !dbg !275
  br label %31, !dbg !276

; <label>:31:                                     ; preds = %30, %27
  %32 = load i8*, i8** %8, align 4, !dbg !277
  %33 = icmp eq i8* %32, null, !dbg !279
  br i1 %33, label %34, label %35, !dbg !280

; <label>:34:                                     ; preds = %31
  store i32 1, i32* %5, align 4, !dbg !281
  br label %27, !dbg !283, !llvm.loop !284

; <label>:35:                                     ; preds = %31
  %36 = load i8*, i8** %8, align 4, !dbg !285
  %37 = bitcast i32** %7 to i8*, !dbg !286
  %38 = call i32 @xQueueReceive(i8* %36, i8* %37, i32 5), !dbg !287
  store i32 0, i32* %6, align 4, !dbg !288
  br label %39, !dbg !290

; <label>:39:                                     ; preds = %48, %35
  %40 = load i32, i32* %6, align 4, !dbg !291
  %41 = icmp slt i32 %40, 10, !dbg !294
  br i1 %41, label %42, label %51, !dbg !295

; <label>:42:                                     ; preds = %39
  %43 = load i32, i32* %6, align 4, !dbg !296
  %44 = load i32*, i32** %7, align 4, !dbg !298
  %45 = getelementptr inbounds i32, i32* %44, i32 %43, !dbg !298
  %46 = load i32, i32* %45, align 4, !dbg !299
  %47 = mul nsw i32 %46, 2, !dbg !299
  store i32 %47, i32* %45, align 4, !dbg !299
  br label %48, !dbg !300

; <label>:48:                                     ; preds = %42
  %49 = load i32, i32* %6, align 4, !dbg !301
  %50 = add nsw i32 %49, 1, !dbg !301
  store i32 %50, i32* %6, align 4, !dbg !301
  br label %39, !dbg !303, !llvm.loop !304

; <label>:51:                                     ; preds = %39
  %52 = load i8*, i8** %9, align 4, !dbg !306
  %53 = bitcast i32** %7 to i8*, !dbg !306
  %54 = call i32 @xQueueGenericSend(i8* %52, i8* %53, i32 5, i32 0), !dbg !306
  br label %27, !dbg !307, !llvm.loop !284
                                                  ; No predecessors!
  ret void, !dbg !309
}

; Function Attrs: nounwind
define void @QPrintTask(i8*) #0 !dbg !310 !xidane.fname !311 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !37 !xidane.ExternC !38 {
  %2 = alloca i8*, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32*, align 4
  %8 = alloca i8*, align 4
  %9 = alloca %struct.QueueData, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !312, metadata !40), !dbg !313
  call void @llvm.dbg.declare(metadata i32* %3, metadata !314, metadata !40), !dbg !315
  call void @llvm.dbg.declare(metadata i32* %4, metadata !316, metadata !40), !dbg !317
  call void @llvm.dbg.declare(metadata i32* %5, metadata !318, metadata !40), !dbg !319
  call void @llvm.dbg.declare(metadata i32* %6, metadata !320, metadata !40), !dbg !321
  call void @llvm.dbg.declare(metadata i32** %7, metadata !322, metadata !40), !dbg !323
  call void @llvm.dbg.declare(metadata i8** %8, metadata !324, metadata !40), !dbg !325
  call void @llvm.dbg.declare(metadata %struct.QueueData* %9, metadata !326, metadata !40), !dbg !327
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.7, i32 0, i32 0)), !dbg !328
  %10 = load i8*, i8** %2, align 4, !dbg !329
  %11 = icmp eq i8* %10, null, !dbg !331
  br i1 %11, label %12, label %13, !dbg !332

; <label>:12:                                     ; preds = %1
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.8, i32 0, i32 0)), !dbg !333
  call void @vTaskDelete(i8* null), !dbg !335
  br label %13, !dbg !336

; <label>:13:                                     ; preds = %12, %1
  %14 = load i8*, i8** %2, align 4, !dbg !337
  %15 = bitcast i8* %14 to %struct.QueueData*, !dbg !338
  %16 = bitcast %struct.QueueData* %9 to i8*, !dbg !339
  %17 = bitcast %struct.QueueData* %15 to i8*, !dbg !339
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %16, i8* %17, i32 16, i32 4, i1 false), !dbg !339
  %18 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 0, !dbg !340
  %19 = load i8*, i8** %18, align 4, !dbg !340
  store i8* %19, i8** %8, align 4, !dbg !341
  %20 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 2, !dbg !342
  %21 = load i32, i32* %20, align 4, !dbg !342
  store i32 %21, i32* %3, align 4, !dbg !343
  %22 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %9, i32 0, i32 3, !dbg !344
  %23 = load i32, i32* %22, align 4, !dbg !344
  store i32 %23, i32* %4, align 4, !dbg !345
  store i32 1, i32* %5, align 4, !dbg !346
  br label %24, !dbg !347

; <label>:24:                                     ; preds = %47, %31, %13
  %25 = load i32, i32* %5, align 4, !dbg !348
  %26 = icmp eq i32 %25, 1, !dbg !353
  br i1 %26, label %27, label %28, !dbg !354

; <label>:27:                                     ; preds = %24
  store i32 0, i32* %5, align 4, !dbg !355
  call void @vTaskDelay(i32 200), !dbg !357
  br label %28, !dbg !358

; <label>:28:                                     ; preds = %27, %24
  %29 = load i8*, i8** %8, align 4, !dbg !359
  %30 = icmp eq i8* %29, null, !dbg !361
  br i1 %30, label %31, label %32, !dbg !362

; <label>:31:                                     ; preds = %28
  store i32 1, i32* %5, align 4, !dbg !363
  br label %24, !dbg !365, !llvm.loop !366

; <label>:32:                                     ; preds = %28
  %33 = load i8*, i8** %8, align 4, !dbg !367
  %34 = bitcast i32** %7 to i8*, !dbg !368
  %35 = call i32 @xQueueReceive(i8* %33, i8* %34, i32 5), !dbg !369
  store i32 0, i32* %6, align 4, !dbg !370
  br label %36, !dbg !372

; <label>:36:                                     ; preds = %44, %32
  %37 = load i32, i32* %6, align 4, !dbg !373
  %38 = icmp slt i32 %37, 10, !dbg !376
  br i1 %38, label %39, label %47, !dbg !377

; <label>:39:                                     ; preds = %36
  %40 = load i32, i32* %6, align 4, !dbg !378
  %41 = load i32*, i32** %7, align 4, !dbg !380
  %42 = getelementptr inbounds i32, i32* %41, i32 %40, !dbg !380
  %43 = load i32, i32* %42, align 4, !dbg !380
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.9, i32 0, i32 0), i32 %43), !dbg !381
  br label %44, !dbg !382

; <label>:44:                                     ; preds = %39
  %45 = load i32, i32* %6, align 4, !dbg !383
  %46 = add nsw i32 %45, 1, !dbg !383
  store i32 %46, i32* %6, align 4, !dbg !383
  br label %36, !dbg !385, !llvm.loop !386

; <label>:47:                                     ; preds = %36
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str.10, i32 0, i32 0)), !dbg !388
  %48 = load i32*, i32** %7, align 4, !dbg !389
  %49 = bitcast i32* %48 to i8*, !dbg !389
  call void @vPortFree(i8* %49), !dbg !390
  br label %24, !dbg !391, !llvm.loop !366
                                                  ; No predecessors!
  ret void, !dbg !393
}

declare !xidane.fname !394 !xidane.function_declaration_type !36 !xidane.function_declaration_filename !129 !xidane.ExternC !38 void @vPortFree(i8*) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!26, !27, !28, !29}
!llvm.ident = !{!30}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src\5CQueueTest.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!2 = !{}
!3 = !{!4, !5, !17, !24}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 32, align: 32)
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueData", file: !7, line: 31, baseType: !8)
!7 = !DIFile(filename: "../src/QueueTest.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!8 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "QueueData", file: !7, line: 25, size: 128, align: 32, elements: !9)
!9 = !{!10, !13, !14, !16}
!10 = !DIDerivedType(tag: DW_TAG_member, name: "inputQueue", scope: !8, file: !7, line: 27, baseType: !11, size: 32, align: 32)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueHandle_t", file: !12, line: 47, baseType: !4)
!12 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!13 = !DIDerivedType(tag: DW_TAG_member, name: "outputQueue", scope: !8, file: !7, line: 28, baseType: !11, size: 32, align: 32, offset: 32)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "queueLength", scope: !8, file: !7, line: 29, baseType: !15, size: 32, align: 32, offset: 64)
!15 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!16 = !DIDerivedType(tag: DW_TAG_member, name: "blockSize", scope: !8, file: !7, line: 30, baseType: !15, size: 32, align: 32, offset: 96)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "TickType_t", file: !18, line: 62, baseType: !19)
!18 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!19 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !20, line: 32, baseType: !21)
!20 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Csys/_stdint.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!21 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !22, line: 65, baseType: !23)
!22 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Cmachine/_default_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!23 = !DIBasicType(name: "unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!24 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !18, line: 59, baseType: !25)
!25 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!26 = !{i32 2, !"Dwarf Version", i32 4}
!27 = !{i32 2, !"Debug Info Version", i32 3}
!28 = !{i32 1, !"wchar_size", i32 4}
!29 = !{i32 1, !"min_enum_size", i32 4}
!30 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!31 = distinct !DISubprogram(name: "QStartTask", scope: !32, file: !32, line: 32, type: !33, isLocal: false, isDefinition: true, scopeLine: 33, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!32 = !DIFile(filename: "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/QueueTest.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
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
!109 = !DILocation(line: 90, column: 3, scope: !110)
!110 = distinct !DILexicalBlock(scope: !79, file: !32, line: 90, column: 3)
!111 = !DILocation(line: 90, column: 3, scope: !79)
!112 = !DILocation(line: 90, column: 3, scope: !113)
!113 = !DILexicalBlockFile(scope: !110, file: !32, discriminator: 1)
!114 = !DILocation(line: 92, column: 3, scope: !79)
!115 = !DILocation(line: 60, column: 2, scope: !116)
!116 = !DILexicalBlockFile(scope: !80, file: !32, discriminator: 1)
!117 = distinct !{!117, !76}
!118 = !DILocation(line: 104, column: 1, scope: !31)
!119 = !{!"xil_printf"}
!120 = !{!"void.const char8 *.1"}
!121 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
!122 = !{!"vTaskDelete"}
!123 = !{!"void.TaskHandle_t.1"}
!124 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h"}
!125 = !{!"vTaskDelay"}
!126 = !{!"void.const TickType_t.0"}
!127 = !{!"pvPortMalloc"}
!128 = !{!"void .size_t.0"}
!129 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portable.h"}
!130 = !{!"vApplicationAssert"}
!131 = !{!"void.const char *.1.uint32_t.0"}
!132 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/FreeRTOSConfig.h"}
!133 = !{!"xQueueGenericSend"}
!134 = !{!"BaseType_t.QueueHandle_t.1.const void *const.1.TickType_t.0.const BaseType_t.0"}
!135 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h"}
!136 = distinct !DISubprogram(name: "QAddTask", scope: !32, file: !32, line: 114, type: !33, isLocal: false, isDefinition: true, scopeLine: 115, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!137 = !{!"QAddTask"}
!138 = !DILocalVariable(name: "parameters", arg: 1, scope: !136, file: !32, line: 114, type: !4)
!139 = !DILocation(line: 114, column: 21, scope: !136)
!140 = !DILocalVariable(name: "queueLength", scope: !136, file: !32, line: 116, type: !15)
!141 = !DILocation(line: 116, column: 6, scope: !136)
!142 = !DILocalVariable(name: "blockSize", scope: !136, file: !32, line: 116, type: !15)
!143 = !DILocation(line: 116, column: 19, scope: !136)
!144 = !DILocalVariable(name: "DelayFlag", scope: !136, file: !32, line: 116, type: !15)
!145 = !DILocation(line: 116, column: 30, scope: !136)
!146 = !DILocalVariable(name: "i", scope: !136, file: !32, line: 116, type: !15)
!147 = !DILocation(line: 116, column: 41, scope: !136)
!148 = !DILocalVariable(name: "array", scope: !136, file: !32, line: 118, type: !51)
!149 = !DILocation(line: 118, column: 8, scope: !136)
!150 = !DILocalVariable(name: "inputQueue", scope: !136, file: !32, line: 120, type: !11)
!151 = !DILocation(line: 120, column: 16, scope: !136)
!152 = !DILocalVariable(name: "outputQueue", scope: !136, file: !32, line: 121, type: !11)
!153 = !DILocation(line: 121, column: 16, scope: !136)
!154 = !DILocation(line: 123, column: 2, scope: !136)
!155 = !DILocalVariable(name: "myQueueData", scope: !136, file: !32, line: 125, type: !6)
!156 = !DILocation(line: 125, column: 12, scope: !136)
!157 = !DILocation(line: 127, column: 6, scope: !158)
!158 = distinct !DILexicalBlock(scope: !136, file: !32, line: 127, column: 6)
!159 = !DILocation(line: 127, column: 17, scope: !158)
!160 = !DILocation(line: 127, column: 6, scope: !136)
!161 = !DILocation(line: 129, column: 3, scope: !162)
!162 = distinct !DILexicalBlock(scope: !158, file: !32, line: 128, column: 2)
!163 = !DILocation(line: 130, column: 3, scope: !162)
!164 = !DILocation(line: 131, column: 2, scope: !162)
!165 = !DILocation(line: 133, column: 32, scope: !136)
!166 = !DILocation(line: 133, column: 18, scope: !136)
!167 = !DILocation(line: 133, column: 16, scope: !136)
!168 = !DILocation(line: 135, column: 27, scope: !136)
!169 = !DILocation(line: 135, column: 13, scope: !136)
!170 = !DILocation(line: 136, column: 28, scope: !136)
!171 = !DILocation(line: 136, column: 14, scope: !136)
!172 = !DILocation(line: 137, column: 28, scope: !136)
!173 = !DILocation(line: 137, column: 14, scope: !136)
!174 = !DILocation(line: 138, column: 26, scope: !136)
!175 = !DILocation(line: 138, column: 12, scope: !136)
!176 = !DILocation(line: 141, column: 12, scope: !136)
!177 = !DILocation(line: 143, column: 2, scope: !136)
!178 = !DILocation(line: 146, column: 6, scope: !179)
!179 = distinct !DILexicalBlock(scope: !180, file: !32, line: 146, column: 6)
!180 = distinct !DILexicalBlock(scope: !181, file: !32, line: 144, column: 2)
!181 = distinct !DILexicalBlock(scope: !182, file: !32, line: 143, column: 2)
!182 = distinct !DILexicalBlock(scope: !136, file: !32, line: 143, column: 2)
!183 = !DILocation(line: 146, column: 16, scope: !179)
!184 = !DILocation(line: 146, column: 6, scope: !180)
!185 = !DILocation(line: 149, column: 14, scope: !186)
!186 = distinct !DILexicalBlock(scope: !179, file: !32, line: 147, column: 3)
!187 = !DILocation(line: 151, column: 4, scope: !186)
!188 = !DILocation(line: 152, column: 3, scope: !186)
!189 = !DILocation(line: 155, column: 7, scope: !190)
!190 = distinct !DILexicalBlock(scope: !180, file: !32, line: 155, column: 7)
!191 = !DILocation(line: 155, column: 18, scope: !190)
!192 = !DILocation(line: 155, column: 7, scope: !180)
!193 = !DILocation(line: 158, column: 14, scope: !194)
!194 = distinct !DILexicalBlock(scope: !190, file: !32, line: 156, column: 3)
!195 = !DILocation(line: 161, column: 4, scope: !194)
!196 = distinct !{!196, !177}
!197 = !DILocation(line: 165, column: 18, scope: !180)
!198 = !DILocation(line: 165, column: 30, scope: !180)
!199 = !DILocation(line: 165, column: 3, scope: !180)
!200 = !DILocation(line: 167, column: 10, scope: !201)
!201 = distinct !DILexicalBlock(scope: !180, file: !32, line: 167, column: 3)
!202 = !DILocation(line: 167, column: 8, scope: !201)
!203 = !DILocation(line: 167, column: 15, scope: !204)
!204 = !DILexicalBlockFile(scope: !205, file: !32, discriminator: 1)
!205 = distinct !DILexicalBlock(scope: !201, file: !32, line: 167, column: 3)
!206 = !DILocation(line: 167, column: 17, scope: !204)
!207 = !DILocation(line: 167, column: 3, scope: !204)
!208 = !DILocation(line: 169, column: 11, scope: !209)
!209 = distinct !DILexicalBlock(scope: !205, file: !32, line: 168, column: 3)
!210 = !DILocation(line: 169, column: 4, scope: !209)
!211 = !DILocation(line: 169, column: 14, scope: !209)
!212 = !DILocation(line: 170, column: 3, scope: !209)
!213 = !DILocation(line: 167, column: 24, scope: !214)
!214 = !DILexicalBlockFile(scope: !205, file: !32, discriminator: 2)
!215 = !DILocation(line: 167, column: 3, scope: !214)
!216 = distinct !{!216, !217}
!217 = !DILocation(line: 167, column: 3, scope: !180)
!218 = !DILocation(line: 172, column: 3, scope: !180)
!219 = !DILocation(line: 143, column: 2, scope: !220)
!220 = !DILexicalBlockFile(scope: !181, file: !32, discriminator: 1)
!221 = !DILocation(line: 183, column: 1, scope: !136)
!222 = !{!"xQueueReceive"}
!223 = !{!"BaseType_t.QueueHandle_t.1.void *const.1.TickType_t.0"}
!224 = distinct !DISubprogram(name: "QMultTask", scope: !32, file: !32, line: 193, type: !33, isLocal: false, isDefinition: true, scopeLine: 194, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!225 = !{!"QMultTask"}
!226 = !DILocalVariable(name: "parameters", arg: 1, scope: !224, file: !32, line: 193, type: !4)
!227 = !DILocation(line: 193, column: 22, scope: !224)
!228 = !DILocalVariable(name: "queueLength", scope: !224, file: !32, line: 195, type: !15)
!229 = !DILocation(line: 195, column: 6, scope: !224)
!230 = !DILocalVariable(name: "blockSize", scope: !224, file: !32, line: 195, type: !15)
!231 = !DILocation(line: 195, column: 19, scope: !224)
!232 = !DILocalVariable(name: "DelayFlag", scope: !224, file: !32, line: 195, type: !15)
!233 = !DILocation(line: 195, column: 30, scope: !224)
!234 = !DILocalVariable(name: "i", scope: !224, file: !32, line: 195, type: !15)
!235 = !DILocation(line: 195, column: 41, scope: !224)
!236 = !DILocalVariable(name: "array", scope: !224, file: !32, line: 197, type: !51)
!237 = !DILocation(line: 197, column: 8, scope: !224)
!238 = !DILocalVariable(name: "inputQueue", scope: !224, file: !32, line: 199, type: !11)
!239 = !DILocation(line: 199, column: 16, scope: !224)
!240 = !DILocalVariable(name: "outputQueue", scope: !224, file: !32, line: 200, type: !11)
!241 = !DILocation(line: 200, column: 16, scope: !224)
!242 = !DILocation(line: 202, column: 2, scope: !224)
!243 = !DILocalVariable(name: "myQueueData", scope: !224, file: !32, line: 204, type: !6)
!244 = !DILocation(line: 204, column: 12, scope: !224)
!245 = !DILocation(line: 206, column: 6, scope: !246)
!246 = distinct !DILexicalBlock(scope: !224, file: !32, line: 206, column: 6)
!247 = !DILocation(line: 206, column: 17, scope: !246)
!248 = !DILocation(line: 206, column: 6, scope: !224)
!249 = !DILocation(line: 208, column: 3, scope: !250)
!250 = distinct !DILexicalBlock(scope: !246, file: !32, line: 207, column: 2)
!251 = !DILocation(line: 209, column: 3, scope: !250)
!252 = !DILocation(line: 210, column: 2, scope: !250)
!253 = !DILocation(line: 212, column: 32, scope: !224)
!254 = !DILocation(line: 212, column: 18, scope: !224)
!255 = !DILocation(line: 212, column: 16, scope: !224)
!256 = !DILocation(line: 214, column: 27, scope: !224)
!257 = !DILocation(line: 214, column: 13, scope: !224)
!258 = !DILocation(line: 215, column: 28, scope: !224)
!259 = !DILocation(line: 215, column: 14, scope: !224)
!260 = !DILocation(line: 216, column: 28, scope: !224)
!261 = !DILocation(line: 216, column: 14, scope: !224)
!262 = !DILocation(line: 217, column: 26, scope: !224)
!263 = !DILocation(line: 217, column: 12, scope: !224)
!264 = !DILocation(line: 220, column: 12, scope: !224)
!265 = !DILocation(line: 222, column: 2, scope: !224)
!266 = !DILocation(line: 225, column: 6, scope: !267)
!267 = distinct !DILexicalBlock(scope: !268, file: !32, line: 225, column: 6)
!268 = distinct !DILexicalBlock(scope: !269, file: !32, line: 223, column: 2)
!269 = distinct !DILexicalBlock(scope: !270, file: !32, line: 222, column: 2)
!270 = distinct !DILexicalBlock(scope: !224, file: !32, line: 222, column: 2)
!271 = !DILocation(line: 225, column: 16, scope: !267)
!272 = !DILocation(line: 225, column: 6, scope: !268)
!273 = !DILocation(line: 228, column: 14, scope: !274)
!274 = distinct !DILexicalBlock(scope: !267, file: !32, line: 226, column: 3)
!275 = !DILocation(line: 230, column: 4, scope: !274)
!276 = !DILocation(line: 231, column: 3, scope: !274)
!277 = !DILocation(line: 234, column: 7, scope: !278)
!278 = distinct !DILexicalBlock(scope: !268, file: !32, line: 234, column: 7)
!279 = !DILocation(line: 234, column: 18, scope: !278)
!280 = !DILocation(line: 234, column: 7, scope: !268)
!281 = !DILocation(line: 237, column: 14, scope: !282)
!282 = distinct !DILexicalBlock(scope: !278, file: !32, line: 235, column: 3)
!283 = !DILocation(line: 240, column: 4, scope: !282)
!284 = distinct !{!284, !265}
!285 = !DILocation(line: 244, column: 18, scope: !268)
!286 = !DILocation(line: 244, column: 30, scope: !268)
!287 = !DILocation(line: 244, column: 3, scope: !268)
!288 = !DILocation(line: 246, column: 10, scope: !289)
!289 = distinct !DILexicalBlock(scope: !268, file: !32, line: 246, column: 3)
!290 = !DILocation(line: 246, column: 8, scope: !289)
!291 = !DILocation(line: 246, column: 15, scope: !292)
!292 = !DILexicalBlockFile(scope: !293, file: !32, discriminator: 1)
!293 = distinct !DILexicalBlock(scope: !289, file: !32, line: 246, column: 3)
!294 = !DILocation(line: 246, column: 17, scope: !292)
!295 = !DILocation(line: 246, column: 3, scope: !292)
!296 = !DILocation(line: 248, column: 11, scope: !297)
!297 = distinct !DILexicalBlock(scope: !293, file: !32, line: 247, column: 3)
!298 = !DILocation(line: 248, column: 4, scope: !297)
!299 = !DILocation(line: 248, column: 14, scope: !297)
!300 = !DILocation(line: 249, column: 3, scope: !297)
!301 = !DILocation(line: 246, column: 24, scope: !302)
!302 = !DILexicalBlockFile(scope: !293, file: !32, discriminator: 2)
!303 = !DILocation(line: 246, column: 3, scope: !302)
!304 = distinct !{!304, !305}
!305 = !DILocation(line: 246, column: 3, scope: !268)
!306 = !DILocation(line: 251, column: 3, scope: !268)
!307 = !DILocation(line: 222, column: 2, scope: !308)
!308 = !DILexicalBlockFile(scope: !269, file: !32, discriminator: 1)
!309 = !DILocation(line: 262, column: 1, scope: !224)
!310 = distinct !DISubprogram(name: "QPrintTask", scope: !32, file: !32, line: 272, type: !33, isLocal: false, isDefinition: true, scopeLine: 273, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!311 = !{!"QPrintTask"}
!312 = !DILocalVariable(name: "parameters", arg: 1, scope: !310, file: !32, line: 272, type: !4)
!313 = !DILocation(line: 272, column: 23, scope: !310)
!314 = !DILocalVariable(name: "queueLength", scope: !310, file: !32, line: 274, type: !15)
!315 = !DILocation(line: 274, column: 6, scope: !310)
!316 = !DILocalVariable(name: "blockSize", scope: !310, file: !32, line: 274, type: !15)
!317 = !DILocation(line: 274, column: 19, scope: !310)
!318 = !DILocalVariable(name: "DelayFlag", scope: !310, file: !32, line: 274, type: !15)
!319 = !DILocation(line: 274, column: 30, scope: !310)
!320 = !DILocalVariable(name: "i", scope: !310, file: !32, line: 274, type: !15)
!321 = !DILocation(line: 274, column: 41, scope: !310)
!322 = !DILocalVariable(name: "array", scope: !310, file: !32, line: 276, type: !51)
!323 = !DILocation(line: 276, column: 8, scope: !310)
!324 = !DILocalVariable(name: "inputQueue", scope: !310, file: !32, line: 278, type: !11)
!325 = !DILocation(line: 278, column: 16, scope: !310)
!326 = !DILocalVariable(name: "myQueueData", scope: !310, file: !32, line: 280, type: !6)
!327 = !DILocation(line: 280, column: 12, scope: !310)
!328 = !DILocation(line: 282, column: 2, scope: !310)
!329 = !DILocation(line: 284, column: 6, scope: !330)
!330 = distinct !DILexicalBlock(scope: !310, file: !32, line: 284, column: 6)
!331 = !DILocation(line: 284, column: 17, scope: !330)
!332 = !DILocation(line: 284, column: 6, scope: !310)
!333 = !DILocation(line: 286, column: 3, scope: !334)
!334 = distinct !DILexicalBlock(scope: !330, file: !32, line: 285, column: 2)
!335 = !DILocation(line: 287, column: 3, scope: !334)
!336 = !DILocation(line: 288, column: 2, scope: !334)
!337 = !DILocation(line: 290, column: 32, scope: !310)
!338 = !DILocation(line: 290, column: 18, scope: !310)
!339 = !DILocation(line: 290, column: 16, scope: !310)
!340 = !DILocation(line: 292, column: 27, scope: !310)
!341 = !DILocation(line: 292, column: 13, scope: !310)
!342 = !DILocation(line: 293, column: 28, scope: !310)
!343 = !DILocation(line: 293, column: 14, scope: !310)
!344 = !DILocation(line: 294, column: 26, scope: !310)
!345 = !DILocation(line: 294, column: 12, scope: !310)
!346 = !DILocation(line: 297, column: 12, scope: !310)
!347 = !DILocation(line: 299, column: 2, scope: !310)
!348 = !DILocation(line: 302, column: 6, scope: !349)
!349 = distinct !DILexicalBlock(scope: !350, file: !32, line: 302, column: 6)
!350 = distinct !DILexicalBlock(scope: !351, file: !32, line: 300, column: 2)
!351 = distinct !DILexicalBlock(scope: !352, file: !32, line: 299, column: 2)
!352 = distinct !DILexicalBlock(scope: !310, file: !32, line: 299, column: 2)
!353 = !DILocation(line: 302, column: 16, scope: !349)
!354 = !DILocation(line: 302, column: 6, scope: !350)
!355 = !DILocation(line: 305, column: 14, scope: !356)
!356 = distinct !DILexicalBlock(scope: !349, file: !32, line: 303, column: 3)
!357 = !DILocation(line: 307, column: 4, scope: !356)
!358 = !DILocation(line: 308, column: 3, scope: !356)
!359 = !DILocation(line: 311, column: 7, scope: !360)
!360 = distinct !DILexicalBlock(scope: !350, file: !32, line: 311, column: 7)
!361 = !DILocation(line: 311, column: 18, scope: !360)
!362 = !DILocation(line: 311, column: 7, scope: !350)
!363 = !DILocation(line: 314, column: 14, scope: !364)
!364 = distinct !DILexicalBlock(scope: !360, file: !32, line: 312, column: 3)
!365 = !DILocation(line: 317, column: 4, scope: !364)
!366 = distinct !{!366, !347}
!367 = !DILocation(line: 321, column: 18, scope: !350)
!368 = !DILocation(line: 321, column: 30, scope: !350)
!369 = !DILocation(line: 321, column: 3, scope: !350)
!370 = !DILocation(line: 323, column: 10, scope: !371)
!371 = distinct !DILexicalBlock(scope: !350, file: !32, line: 323, column: 3)
!372 = !DILocation(line: 323, column: 8, scope: !371)
!373 = !DILocation(line: 323, column: 15, scope: !374)
!374 = !DILexicalBlockFile(scope: !375, file: !32, discriminator: 1)
!375 = distinct !DILexicalBlock(scope: !371, file: !32, line: 323, column: 3)
!376 = !DILocation(line: 323, column: 17, scope: !374)
!377 = !DILocation(line: 323, column: 3, scope: !374)
!378 = !DILocation(line: 325, column: 29, scope: !379)
!379 = distinct !DILexicalBlock(scope: !375, file: !32, line: 324, column: 3)
!380 = !DILocation(line: 325, column: 23, scope: !379)
!381 = !DILocation(line: 325, column: 4, scope: !379)
!382 = !DILocation(line: 326, column: 3, scope: !379)
!383 = !DILocation(line: 323, column: 24, scope: !384)
!384 = !DILexicalBlockFile(scope: !375, file: !32, discriminator: 2)
!385 = !DILocation(line: 323, column: 3, scope: !384)
!386 = distinct !{!386, !387}
!387 = !DILocation(line: 323, column: 3, scope: !350)
!388 = !DILocation(line: 327, column: 3, scope: !350)
!389 = !DILocation(line: 329, column: 13, scope: !350)
!390 = !DILocation(line: 329, column: 3, scope: !350)
!391 = !DILocation(line: 299, column: 2, scope: !392)
!392 = !DILexicalBlockFile(scope: !351, file: !32, discriminator: 1)
!393 = !DILocation(line: 340, column: 1, scope: !310)
!394 = !{!"vPortFree"}
