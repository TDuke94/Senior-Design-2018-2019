; ModuleID = 'C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c'
source_filename = "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c"
target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "armv7-none--eabi"

%struct.QueueData = type { i8*, i8*, i32, i32 }

@.str = private unnamed_addr constant [7 x i8] c"QStart\00", align 1
@.str.1 = private unnamed_addr constant [5 x i8] c"QAdd\00", align 1
@.str.2 = private unnamed_addr constant [6 x i8] c"QMult\00", align 1
@.str.3 = private unnamed_addr constant [7 x i8] c"QPrint\00", align 1
@.str.4 = private unnamed_addr constant [23 x i8] c"error in creating task\00", align 1

; Function Attrs: nounwind
define void @dispatchPipeline() #0 !dbg !20 !xidane.fname !24 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !26 !xidane.ExternC !27 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i8*, align 4
  %5 = alloca i8*, align 4
  %6 = alloca i8*, align 4
  %7 = alloca %struct.QueueData*, align 4
  %8 = alloca i32, align 4
  %9 = alloca i8*, align 4
  %10 = alloca i8*, align 4
  %11 = alloca i8*, align 4
  %12 = alloca i8*, align 4
  call void @llvm.dbg.declare(metadata i32* %1, metadata !28, metadata !30), !dbg !31
  store i32 400, i32* %1, align 4, !dbg !31
  call void @llvm.dbg.declare(metadata i32* %2, metadata !32, metadata !30), !dbg !33
  store i32 5, i32* %2, align 4, !dbg !33
  call void @llvm.dbg.declare(metadata i32* %3, metadata !34, metadata !30), !dbg !35
  store i32 5, i32* %3, align 4, !dbg !35
  call void @llvm.dbg.declare(metadata i8** %4, metadata !36, metadata !30), !dbg !39
  call void @llvm.dbg.declare(metadata i8** %5, metadata !40, metadata !30), !dbg !41
  call void @llvm.dbg.declare(metadata i8** %6, metadata !42, metadata !30), !dbg !43
  call void @llvm.dbg.declare(metadata %struct.QueueData** %7, metadata !44, metadata !30), !dbg !54
  call void @llvm.dbg.declare(metadata i32* %8, metadata !55, metadata !30), !dbg !56
  call void @llvm.dbg.declare(metadata i8** %9, metadata !57, metadata !30), !dbg !60
  store i8* null, i8** %9, align 4, !dbg !60
  call void @llvm.dbg.declare(metadata i8** %10, metadata !61, metadata !30), !dbg !62
  store i8* null, i8** %10, align 4, !dbg !62
  call void @llvm.dbg.declare(metadata i8** %11, metadata !63, metadata !30), !dbg !64
  store i8* null, i8** %11, align 4, !dbg !64
  call void @llvm.dbg.declare(metadata i8** %12, metadata !65, metadata !30), !dbg !66
  store i8* null, i8** %12, align 4, !dbg !66
  %13 = load i32, i32* %2, align 4, !dbg !67
  %14 = load i32, i32* %3, align 4, !dbg !67
  %15 = call i8* @xQueueGenericCreate(i32 %13, i32 %14, i8 zeroext 0), !dbg !67
  store i8* %15, i8** %4, align 4, !dbg !68
  %16 = load i32, i32* %2, align 4, !dbg !69
  %17 = load i32, i32* %3, align 4, !dbg !69
  %18 = call i8* @xQueueGenericCreate(i32 %16, i32 %17, i8 zeroext 0), !dbg !69
  store i8* %18, i8** %5, align 4, !dbg !70
  %19 = load i32, i32* %2, align 4, !dbg !71
  %20 = load i32, i32* %3, align 4, !dbg !71
  %21 = call i8* @xQueueGenericCreate(i32 %19, i32 %20, i8 zeroext 0), !dbg !71
  store i8* %21, i8** %6, align 4, !dbg !72
  %22 = call i8* @pvPortMalloc(i32 16), !dbg !73
  %23 = bitcast i8* %22 to %struct.QueueData*, !dbg !73
  store %struct.QueueData* %23, %struct.QueueData** %7, align 4, !dbg !74
  %24 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !75
  %25 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %24, i32 0, i32 0, !dbg !76
  store i8* null, i8** %25, align 4, !dbg !77
  %26 = load i8*, i8** %4, align 4, !dbg !78
  %27 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !79
  %28 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %27, i32 0, i32 1, !dbg !80
  store i8* %26, i8** %28, align 4, !dbg !81
  %29 = load i32, i32* %2, align 4, !dbg !82
  %30 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !83
  %31 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %30, i32 0, i32 2, !dbg !84
  store i32 %29, i32* %31, align 4, !dbg !85
  %32 = load i32, i32* %3, align 4, !dbg !86
  %33 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !87
  %34 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %33, i32 0, i32 3, !dbg !88
  store i32 %32, i32* %34, align 4, !dbg !89
  %35 = load i32, i32* %1, align 4, !dbg !90
  %36 = trunc i32 %35 to i16, !dbg !90
  %37 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !91
  %38 = bitcast %struct.QueueData* %37 to i8*, !dbg !92
  %39 = call i32 @xTaskCreate(void (i8*)* @QStartTask, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i32 0, i32 0), i16 zeroext %36, i8* %38, i32 1, i8** %9), !dbg !93
  store i32 %39, i32* %8, align 4, !dbg !94
  %40 = load i32, i32* %8, align 4, !dbg !95
  %41 = icmp ne i32 %40, 1, !dbg !97
  br i1 %41, label %42, label %43, !dbg !98

; <label>:42:                                     ; preds = %0
  call void @printError(), !dbg !99
  br label %43, !dbg !99

; <label>:43:                                     ; preds = %42, %0
  %44 = load i8*, i8** %4, align 4, !dbg !101
  %45 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !102
  %46 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %45, i32 0, i32 0, !dbg !103
  store i8* %44, i8** %46, align 4, !dbg !104
  %47 = load i8*, i8** %5, align 4, !dbg !105
  %48 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !106
  %49 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %48, i32 0, i32 1, !dbg !107
  store i8* %47, i8** %49, align 4, !dbg !108
  %50 = load i32, i32* %2, align 4, !dbg !109
  %51 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !110
  %52 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %51, i32 0, i32 2, !dbg !111
  store i32 %50, i32* %52, align 4, !dbg !112
  %53 = load i32, i32* %3, align 4, !dbg !113
  %54 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !114
  %55 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %54, i32 0, i32 3, !dbg !115
  store i32 %53, i32* %55, align 4, !dbg !116
  %56 = load i32, i32* %1, align 4, !dbg !117
  %57 = trunc i32 %56 to i16, !dbg !117
  %58 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !118
  %59 = bitcast %struct.QueueData* %58 to i8*, !dbg !119
  %60 = call i32 @xTaskCreate(void (i8*)* @QAddTask, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.1, i32 0, i32 0), i16 zeroext %57, i8* %59, i32 1, i8** %10), !dbg !120
  store i32 %60, i32* %8, align 4, !dbg !121
  %61 = load i32, i32* %8, align 4, !dbg !122
  %62 = icmp ne i32 %61, 1, !dbg !124
  br i1 %62, label %63, label %64, !dbg !125

; <label>:63:                                     ; preds = %43
  call void @printError(), !dbg !126
  br label %64, !dbg !126

; <label>:64:                                     ; preds = %63, %43
  %65 = load i8*, i8** %5, align 4, !dbg !128
  %66 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !129
  %67 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %66, i32 0, i32 0, !dbg !130
  store i8* %65, i8** %67, align 4, !dbg !131
  %68 = load i8*, i8** %6, align 4, !dbg !132
  %69 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !133
  %70 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %69, i32 0, i32 1, !dbg !134
  store i8* %68, i8** %70, align 4, !dbg !135
  %71 = load i32, i32* %2, align 4, !dbg !136
  %72 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !137
  %73 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %72, i32 0, i32 2, !dbg !138
  store i32 %71, i32* %73, align 4, !dbg !139
  %74 = load i32, i32* %3, align 4, !dbg !140
  %75 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !141
  %76 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %75, i32 0, i32 3, !dbg !142
  store i32 %74, i32* %76, align 4, !dbg !143
  %77 = load i32, i32* %1, align 4, !dbg !144
  %78 = trunc i32 %77 to i16, !dbg !144
  %79 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !145
  %80 = bitcast %struct.QueueData* %79 to i8*, !dbg !146
  %81 = call i32 @xTaskCreate(void (i8*)* @QMultTask, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.2, i32 0, i32 0), i16 zeroext %78, i8* %80, i32 1, i8** %11), !dbg !147
  store i32 %81, i32* %8, align 4, !dbg !148
  %82 = load i32, i32* %8, align 4, !dbg !149
  %83 = icmp ne i32 %82, 1, !dbg !151
  br i1 %83, label %84, label %85, !dbg !152

; <label>:84:                                     ; preds = %64
  call void @printError(), !dbg !153
  br label %85, !dbg !153

; <label>:85:                                     ; preds = %84, %64
  %86 = load i8*, i8** %6, align 4, !dbg !155
  %87 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !156
  %88 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %87, i32 0, i32 0, !dbg !157
  store i8* %86, i8** %88, align 4, !dbg !158
  %89 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !159
  %90 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %89, i32 0, i32 1, !dbg !160
  store i8* null, i8** %90, align 4, !dbg !161
  %91 = load i32, i32* %2, align 4, !dbg !162
  %92 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !163
  %93 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %92, i32 0, i32 2, !dbg !164
  store i32 %91, i32* %93, align 4, !dbg !165
  %94 = load i32, i32* %3, align 4, !dbg !166
  %95 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !167
  %96 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %95, i32 0, i32 3, !dbg !168
  store i32 %94, i32* %96, align 4, !dbg !169
  %97 = load i32, i32* %1, align 4, !dbg !170
  %98 = trunc i32 %97 to i16, !dbg !170
  %99 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !171
  %100 = bitcast %struct.QueueData* %99 to i8*, !dbg !172
  %101 = call i32 @xTaskCreate(void (i8*)* @QPrintTask, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.3, i32 0, i32 0), i16 zeroext %98, i8* %100, i32 1, i8** %12), !dbg !173
  store i32 %101, i32* %8, align 4, !dbg !174
  %102 = load i32, i32* %8, align 4, !dbg !175
  %103 = icmp ne i32 %102, 1, !dbg !177
  br i1 %103, label %104, label %105, !dbg !178

; <label>:104:                                    ; preds = %85
  call void @printError(), !dbg !179
  br label %105, !dbg !179

; <label>:105:                                    ; preds = %104, %85
  call void @vTaskStartScheduler(), !dbg !181
  ret void, !dbg !182
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !183 !xidane.function_declaration_type !184 !xidane.function_declaration_filename !185 !xidane.ExternC !27 i8* @xQueueGenericCreate(i32, i32, i8 zeroext) #2

declare !xidane.fname !186 !xidane.function_declaration_type !187 !xidane.function_declaration_filename !188 !xidane.ExternC !27 i8* @pvPortMalloc(i32) #2

declare !xidane.fname !189 !xidane.function_declaration_type !190 !xidane.function_declaration_filename !191 !xidane.ExternC !27 i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, i8**) #2

declare !xidane.fname !192 !xidane.function_declaration_type !193 !xidane.function_declaration_filename !194 !xidane.ExternC !27 void @QStartTask(i8*) #2

; Function Attrs: nounwind
define void @printError() #0 !dbg !195 !xidane.fname !196 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !197 !xidane.ExternC !27 {
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i32 0, i32 0)), !dbg !198
  ret void, !dbg !199
}

declare !xidane.fname !200 !xidane.function_declaration_type !193 !xidane.function_declaration_filename !194 !xidane.ExternC !27 void @QAddTask(i8*) #2

declare !xidane.fname !201 !xidane.function_declaration_type !193 !xidane.function_declaration_filename !194 !xidane.ExternC !27 void @QMultTask(i8*) #2

declare !xidane.fname !202 !xidane.function_declaration_type !193 !xidane.function_declaration_filename !194 !xidane.ExternC !27 void @QPrintTask(i8*) #2

declare !xidane.fname !203 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !191 !xidane.ExternC !27 void @vTaskStartScheduler() #2

; Function Attrs: nounwind
define void @continualDispatcher(i8*) #0 !dbg !204 !xidane.fname !207 !xidane.function_declaration_type !193 !xidane.function_declaration_filename !26 !xidane.ExternC !27 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !208, metadata !30), !dbg !209
  ret void, !dbg !210
}

declare !xidane.fname !211 !xidane.function_declaration_type !212 !xidane.function_declaration_filename !213 !xidane.ExternC !27 void @xil_printf(i8*, ...) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!15, !16, !17, !18}
!llvm.ident = !{!19}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src\5Cdispatch.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!2 = !{}
!3 = !{!4, !5, !10, !13}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !6, line: 20, baseType: !7)
!6 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Csys/_stdint.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !8, line: 29, baseType: !9)
!8 = !DIFile(filename: "E:/SDSoC/SDK/2018.2/gnu/aarch32/nt/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include\5Cmachine/_default_types.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!9 = !DIBasicType(name: "unsigned char", size: 8, align: 8, encoding: DW_ATE_unsigned_char)
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "UBaseType_t", file: !11, line: 60, baseType: !12)
!11 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!12 = !DIBasicType(name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!13 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !11, line: 59, baseType: !14)
!14 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!15 = !{i32 2, !"Dwarf Version", i32 4}
!16 = !{i32 2, !"Debug Info Version", i32 3}
!17 = !{i32 1, !"wchar_size", i32 4}
!18 = !{i32 1, !"min_enum_size", i32 4}
!19 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!20 = distinct !DISubprogram(name: "dispatchPipeline", scope: !21, file: !21, line: 33, type: !22, isLocal: false, isDefinition: true, scopeLine: 34, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!21 = !DIFile(filename: "C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!22 = !DISubroutineType(types: !23)
!23 = !{null}
!24 = !{!"dispatchPipeline"}
!25 = !{!"void."}
!26 = !{!"../src/dispatch.h"}
!27 = !{!"t"}
!28 = !DILocalVariable(name: "STACK_SIZE", scope: !20, file: !21, line: 35, type: !29)
!29 = !DIBasicType(name: "int", size: 32, align: 32, encoding: DW_ATE_signed)
!30 = !DIExpression()
!31 = !DILocation(line: 35, column: 6, scope: !20)
!32 = !DILocalVariable(name: "QueueLength", scope: !20, file: !21, line: 36, type: !29)
!33 = !DILocation(line: 36, column: 6, scope: !20)
!34 = !DILocalVariable(name: "BlockSize", scope: !20, file: !21, line: 37, type: !29)
!35 = !DILocation(line: 37, column: 6, scope: !20)
!36 = !DILocalVariable(name: "Queue_1", scope: !20, file: !21, line: 39, type: !37)
!37 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueHandle_t", file: !38, line: 47, baseType: !4)
!38 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!39 = !DILocation(line: 39, column: 16, scope: !20)
!40 = !DILocalVariable(name: "Queue_2", scope: !20, file: !21, line: 39, type: !37)
!41 = !DILocation(line: 39, column: 25, scope: !20)
!42 = !DILocalVariable(name: "Queue_3", scope: !20, file: !21, line: 39, type: !37)
!43 = !DILocation(line: 39, column: 34, scope: !20)
!44 = !DILocalVariable(name: "Q_Data", scope: !20, file: !21, line: 41, type: !45)
!45 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !46, size: 32, align: 32)
!46 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueData", file: !47, line: 31, baseType: !48)
!47 = !DIFile(filename: "../src/QueueTest.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!48 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "QueueData", file: !47, line: 25, size: 128, align: 32, elements: !49)
!49 = !{!50, !51, !52, !53}
!50 = !DIDerivedType(tag: DW_TAG_member, name: "inputQueue", scope: !48, file: !47, line: 27, baseType: !37, size: 32, align: 32)
!51 = !DIDerivedType(tag: DW_TAG_member, name: "outputQueue", scope: !48, file: !47, line: 28, baseType: !37, size: 32, align: 32, offset: 32)
!52 = !DIDerivedType(tag: DW_TAG_member, name: "queueLength", scope: !48, file: !47, line: 29, baseType: !29, size: 32, align: 32, offset: 64)
!53 = !DIDerivedType(tag: DW_TAG_member, name: "blockSize", scope: !48, file: !47, line: 30, baseType: !29, size: 32, align: 32, offset: 96)
!54 = !DILocation(line: 41, column: 13, scope: !20)
!55 = !DILocalVariable(name: "xReturned", scope: !20, file: !21, line: 43, type: !13)
!56 = !DILocation(line: 43, column: 13, scope: !20)
!57 = !DILocalVariable(name: "xQStartHandle", scope: !20, file: !21, line: 45, type: !58)
!58 = !DIDerivedType(tag: DW_TAG_typedef, name: "TaskHandle_t", file: !59, line: 62, baseType: !4)
!59 = !DIFile(filename: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h", directory: "C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArtyFreeTest\5CDebug")
!60 = !DILocation(line: 45, column: 15, scope: !20)
!61 = !DILocalVariable(name: "xQAddHandle", scope: !20, file: !21, line: 46, type: !58)
!62 = !DILocation(line: 46, column: 15, scope: !20)
!63 = !DILocalVariable(name: "xQMultHandle", scope: !20, file: !21, line: 47, type: !58)
!64 = !DILocation(line: 47, column: 15, scope: !20)
!65 = !DILocalVariable(name: "xQPrintHandle", scope: !20, file: !21, line: 48, type: !58)
!66 = !DILocation(line: 48, column: 15, scope: !20)
!67 = !DILocation(line: 53, column: 12, scope: !20)
!68 = !DILocation(line: 53, column: 10, scope: !20)
!69 = !DILocation(line: 54, column: 12, scope: !20)
!70 = !DILocation(line: 54, column: 10, scope: !20)
!71 = !DILocation(line: 55, column: 12, scope: !20)
!72 = !DILocation(line: 55, column: 10, scope: !20)
!73 = !DILocation(line: 64, column: 11, scope: !20)
!74 = !DILocation(line: 64, column: 9, scope: !20)
!75 = !DILocation(line: 67, column: 2, scope: !20)
!76 = !DILocation(line: 67, column: 10, scope: !20)
!77 = !DILocation(line: 67, column: 21, scope: !20)
!78 = !DILocation(line: 68, column: 24, scope: !20)
!79 = !DILocation(line: 68, column: 2, scope: !20)
!80 = !DILocation(line: 68, column: 10, scope: !20)
!81 = !DILocation(line: 68, column: 22, scope: !20)
!82 = !DILocation(line: 69, column: 24, scope: !20)
!83 = !DILocation(line: 69, column: 2, scope: !20)
!84 = !DILocation(line: 69, column: 10, scope: !20)
!85 = !DILocation(line: 69, column: 22, scope: !20)
!86 = !DILocation(line: 70, column: 22, scope: !20)
!87 = !DILocation(line: 70, column: 2, scope: !20)
!88 = !DILocation(line: 70, column: 10, scope: !20)
!89 = !DILocation(line: 70, column: 20, scope: !20)
!90 = !DILocation(line: 75, column: 6, scope: !20)
!91 = !DILocation(line: 76, column: 15, scope: !20)
!92 = !DILocation(line: 76, column: 6, scope: !20)
!93 = !DILocation(line: 72, column: 14, scope: !20)
!94 = !DILocation(line: 72, column: 12, scope: !20)
!95 = !DILocation(line: 81, column: 6, scope: !96)
!96 = distinct !DILexicalBlock(scope: !20, file: !21, line: 81, column: 6)
!97 = !DILocation(line: 81, column: 16, scope: !96)
!98 = !DILocation(line: 81, column: 6, scope: !20)
!99 = !DILocation(line: 81, column: 27, scope: !100)
!100 = !DILexicalBlockFile(scope: !96, file: !21, discriminator: 1)
!101 = !DILocation(line: 84, column: 23, scope: !20)
!102 = !DILocation(line: 84, column: 2, scope: !20)
!103 = !DILocation(line: 84, column: 10, scope: !20)
!104 = !DILocation(line: 84, column: 21, scope: !20)
!105 = !DILocation(line: 85, column: 24, scope: !20)
!106 = !DILocation(line: 85, column: 2, scope: !20)
!107 = !DILocation(line: 85, column: 10, scope: !20)
!108 = !DILocation(line: 85, column: 22, scope: !20)
!109 = !DILocation(line: 86, column: 24, scope: !20)
!110 = !DILocation(line: 86, column: 2, scope: !20)
!111 = !DILocation(line: 86, column: 10, scope: !20)
!112 = !DILocation(line: 86, column: 22, scope: !20)
!113 = !DILocation(line: 87, column: 22, scope: !20)
!114 = !DILocation(line: 87, column: 2, scope: !20)
!115 = !DILocation(line: 87, column: 10, scope: !20)
!116 = !DILocation(line: 87, column: 20, scope: !20)
!117 = !DILocation(line: 92, column: 6, scope: !20)
!118 = !DILocation(line: 93, column: 15, scope: !20)
!119 = !DILocation(line: 93, column: 6, scope: !20)
!120 = !DILocation(line: 89, column: 14, scope: !20)
!121 = !DILocation(line: 89, column: 12, scope: !20)
!122 = !DILocation(line: 98, column: 6, scope: !123)
!123 = distinct !DILexicalBlock(scope: !20, file: !21, line: 98, column: 6)
!124 = !DILocation(line: 98, column: 16, scope: !123)
!125 = !DILocation(line: 98, column: 6, scope: !20)
!126 = !DILocation(line: 98, column: 27, scope: !127)
!127 = !DILexicalBlockFile(scope: !123, file: !21, discriminator: 1)
!128 = !DILocation(line: 101, column: 23, scope: !20)
!129 = !DILocation(line: 101, column: 2, scope: !20)
!130 = !DILocation(line: 101, column: 10, scope: !20)
!131 = !DILocation(line: 101, column: 21, scope: !20)
!132 = !DILocation(line: 102, column: 24, scope: !20)
!133 = !DILocation(line: 102, column: 2, scope: !20)
!134 = !DILocation(line: 102, column: 10, scope: !20)
!135 = !DILocation(line: 102, column: 22, scope: !20)
!136 = !DILocation(line: 103, column: 24, scope: !20)
!137 = !DILocation(line: 103, column: 2, scope: !20)
!138 = !DILocation(line: 103, column: 10, scope: !20)
!139 = !DILocation(line: 103, column: 22, scope: !20)
!140 = !DILocation(line: 104, column: 22, scope: !20)
!141 = !DILocation(line: 104, column: 2, scope: !20)
!142 = !DILocation(line: 104, column: 10, scope: !20)
!143 = !DILocation(line: 104, column: 20, scope: !20)
!144 = !DILocation(line: 109, column: 6, scope: !20)
!145 = !DILocation(line: 110, column: 15, scope: !20)
!146 = !DILocation(line: 110, column: 6, scope: !20)
!147 = !DILocation(line: 106, column: 14, scope: !20)
!148 = !DILocation(line: 106, column: 12, scope: !20)
!149 = !DILocation(line: 115, column: 6, scope: !150)
!150 = distinct !DILexicalBlock(scope: !20, file: !21, line: 115, column: 6)
!151 = !DILocation(line: 115, column: 16, scope: !150)
!152 = !DILocation(line: 115, column: 6, scope: !20)
!153 = !DILocation(line: 115, column: 27, scope: !154)
!154 = !DILexicalBlockFile(scope: !150, file: !21, discriminator: 1)
!155 = !DILocation(line: 118, column: 23, scope: !20)
!156 = !DILocation(line: 118, column: 2, scope: !20)
!157 = !DILocation(line: 118, column: 10, scope: !20)
!158 = !DILocation(line: 118, column: 21, scope: !20)
!159 = !DILocation(line: 119, column: 2, scope: !20)
!160 = !DILocation(line: 119, column: 10, scope: !20)
!161 = !DILocation(line: 119, column: 22, scope: !20)
!162 = !DILocation(line: 120, column: 24, scope: !20)
!163 = !DILocation(line: 120, column: 2, scope: !20)
!164 = !DILocation(line: 120, column: 10, scope: !20)
!165 = !DILocation(line: 120, column: 22, scope: !20)
!166 = !DILocation(line: 121, column: 22, scope: !20)
!167 = !DILocation(line: 121, column: 2, scope: !20)
!168 = !DILocation(line: 121, column: 10, scope: !20)
!169 = !DILocation(line: 121, column: 20, scope: !20)
!170 = !DILocation(line: 126, column: 6, scope: !20)
!171 = !DILocation(line: 127, column: 15, scope: !20)
!172 = !DILocation(line: 127, column: 6, scope: !20)
!173 = !DILocation(line: 123, column: 14, scope: !20)
!174 = !DILocation(line: 123, column: 12, scope: !20)
!175 = !DILocation(line: 132, column: 6, scope: !176)
!176 = distinct !DILexicalBlock(scope: !20, file: !21, line: 132, column: 6)
!177 = !DILocation(line: 132, column: 16, scope: !176)
!178 = !DILocation(line: 132, column: 6, scope: !20)
!179 = !DILocation(line: 132, column: 27, scope: !180)
!180 = !DILexicalBlockFile(scope: !176, file: !21, discriminator: 1)
!181 = !DILocation(line: 135, column: 2, scope: !20)
!182 = !DILocation(line: 138, column: 2, scope: !20)
!183 = !{!"xQueueGenericCreate"}
!184 = !{!"QueueHandle_t.const UBaseType_t.0.const UBaseType_t.0.const uint8_t.0"}
!185 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Cqueue.h"}
!186 = !{!"pvPortMalloc"}
!187 = !{!"void .size_t.0"}
!188 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portable.h"}
!189 = !{!"xTaskCreate"}
!190 = !{!"BaseType_t.TaskFunction_t.1.const char *const.1.const uint16_t.0.void *const.1.UBaseType_t.0.TaskHandle_t *const.1"}
!191 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp\5Ctask.h"}
!192 = !{!"QStartTask"}
!193 = !{!"void.void *.1"}
!194 = !{!"../src/QueueTest.h"}
!195 = distinct !DISubprogram(name: "printError", scope: !21, file: !21, line: 152, type: !22, isLocal: false, isDefinition: true, scopeLine: 153, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!196 = !{!"printError"}
!197 = !{!"C:/Users/TimothyDuke/workspace/ArtyFreeTest/src/dispatch.c"}
!198 = !DILocation(line: 154, column: 2, scope: !195)
!199 = !DILocation(line: 155, column: 1, scope: !195)
!200 = !{!"QAddTask"}
!201 = !{!"QMultTask"}
!202 = !{!"QPrintTask"}
!203 = !{!"vTaskStartScheduler"}
!204 = distinct !DISubprogram(name: "continualDispatcher", scope: !21, file: !21, line: 146, type: !205, isLocal: false, isDefinition: true, scopeLine: 147, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!205 = !DISubroutineType(types: !206)
!206 = !{null, !4}
!207 = !{!"continualDispatcher"}
!208 = !DILocalVariable(name: "parameter", arg: 1, scope: !204, file: !21, line: 146, type: !4)
!209 = !DILocation(line: 146, column: 34, scope: !204)
!210 = !DILocation(line: 149, column: 2, scope: !204)
!211 = !{!"xil_printf"}
!212 = !{!"void.const char8 *.1"}
!213 = !{!"C:\5CUsers\5CTimothyDuke\5Cworkspace\5CArty_Z7_20\5Cexport\5CArty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
