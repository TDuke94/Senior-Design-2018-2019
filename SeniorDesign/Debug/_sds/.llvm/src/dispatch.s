; ModuleID = '/home/timothyduke/workspace/SeniorDesign/src/dispatch.c'
source_filename = "/home/timothyduke/workspace/SeniorDesign/src/dispatch.c"
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
  %8 = alloca %struct.QueueData*, align 4
  %9 = alloca %struct.QueueData*, align 4
  %10 = alloca %struct.QueueData*, align 4
  %11 = alloca i32, align 4
  %12 = alloca i8*, align 4
  %13 = alloca i8*, align 4
  %14 = alloca i8*, align 4
  %15 = alloca i8*, align 4
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
  call void @llvm.dbg.declare(metadata %struct.QueueData** %8, metadata !55, metadata !30), !dbg !56
  call void @llvm.dbg.declare(metadata %struct.QueueData** %9, metadata !57, metadata !30), !dbg !58
  call void @llvm.dbg.declare(metadata %struct.QueueData** %10, metadata !59, metadata !30), !dbg !60
  call void @llvm.dbg.declare(metadata i32* %11, metadata !61, metadata !30), !dbg !62
  call void @llvm.dbg.declare(metadata i8** %12, metadata !63, metadata !30), !dbg !66
  store i8* null, i8** %12, align 4, !dbg !66
  call void @llvm.dbg.declare(metadata i8** %13, metadata !67, metadata !30), !dbg !68
  store i8* null, i8** %13, align 4, !dbg !68
  call void @llvm.dbg.declare(metadata i8** %14, metadata !69, metadata !30), !dbg !70
  store i8* null, i8** %14, align 4, !dbg !70
  call void @llvm.dbg.declare(metadata i8** %15, metadata !71, metadata !30), !dbg !72
  store i8* null, i8** %15, align 4, !dbg !72
  %16 = load i32, i32* %2, align 4, !dbg !73
  %17 = load i32, i32* %3, align 4, !dbg !73
  %18 = call i8* @xQueueGenericCreate(i32 %16, i32 %17, i8 zeroext 0), !dbg !73
  store i8* %18, i8** %4, align 4, !dbg !74
  %19 = load i32, i32* %2, align 4, !dbg !75
  %20 = load i32, i32* %3, align 4, !dbg !75
  %21 = call i8* @xQueueGenericCreate(i32 %19, i32 %20, i8 zeroext 0), !dbg !75
  store i8* %21, i8** %5, align 4, !dbg !76
  %22 = load i32, i32* %2, align 4, !dbg !77
  %23 = load i32, i32* %3, align 4, !dbg !77
  %24 = call i8* @xQueueGenericCreate(i32 %22, i32 %23, i8 zeroext 0), !dbg !77
  store i8* %24, i8** %6, align 4, !dbg !78
  %25 = call i8* @pvPortMalloc(i32 16), !dbg !79
  %26 = bitcast i8* %25 to %struct.QueueData*, !dbg !79
  store %struct.QueueData* %26, %struct.QueueData** %7, align 4, !dbg !80
  %27 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !81
  %28 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %27, i32 0, i32 0, !dbg !82
  store i8* null, i8** %28, align 4, !dbg !83
  %29 = load i8*, i8** %4, align 4, !dbg !84
  %30 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !85
  %31 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %30, i32 0, i32 1, !dbg !86
  store i8* %29, i8** %31, align 4, !dbg !87
  %32 = load i32, i32* %2, align 4, !dbg !88
  %33 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !89
  %34 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %33, i32 0, i32 2, !dbg !90
  store i32 %32, i32* %34, align 4, !dbg !91
  %35 = load i32, i32* %3, align 4, !dbg !92
  %36 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !93
  %37 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %36, i32 0, i32 3, !dbg !94
  store i32 %35, i32* %37, align 4, !dbg !95
  %38 = load i32, i32* %1, align 4, !dbg !96
  %39 = trunc i32 %38 to i16, !dbg !96
  %40 = load %struct.QueueData*, %struct.QueueData** %7, align 4, !dbg !97
  %41 = bitcast %struct.QueueData* %40 to i8*, !dbg !98
  %42 = call i32 @xTaskCreate(void (i8*)* @QStartTask, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str, i32 0, i32 0), i16 zeroext %39, i8* %41, i32 1, i8** %12), !dbg !99
  store i32 %42, i32* %11, align 4, !dbg !100
  %43 = load i32, i32* %11, align 4, !dbg !101
  %44 = icmp ne i32 %43, 1, !dbg !103
  br i1 %44, label %45, label %46, !dbg !104

; <label>:45:                                     ; preds = %0
  call void @printError(), !dbg !105
  br label %46, !dbg !105

; <label>:46:                                     ; preds = %45, %0
  %47 = call i8* @pvPortMalloc(i32 16), !dbg !107
  %48 = bitcast i8* %47 to %struct.QueueData*, !dbg !107
  store %struct.QueueData* %48, %struct.QueueData** %8, align 4, !dbg !108
  %49 = load i8*, i8** %4, align 4, !dbg !109
  %50 = load %struct.QueueData*, %struct.QueueData** %8, align 4, !dbg !110
  %51 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %50, i32 0, i32 0, !dbg !111
  store i8* %49, i8** %51, align 4, !dbg !112
  %52 = load i8*, i8** %5, align 4, !dbg !113
  %53 = load %struct.QueueData*, %struct.QueueData** %8, align 4, !dbg !114
  %54 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %53, i32 0, i32 1, !dbg !115
  store i8* %52, i8** %54, align 4, !dbg !116
  %55 = load i32, i32* %2, align 4, !dbg !117
  %56 = load %struct.QueueData*, %struct.QueueData** %8, align 4, !dbg !118
  %57 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %56, i32 0, i32 2, !dbg !119
  store i32 %55, i32* %57, align 4, !dbg !120
  %58 = load i32, i32* %3, align 4, !dbg !121
  %59 = load %struct.QueueData*, %struct.QueueData** %8, align 4, !dbg !122
  %60 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %59, i32 0, i32 3, !dbg !123
  store i32 %58, i32* %60, align 4, !dbg !124
  %61 = load i32, i32* %1, align 4, !dbg !125
  %62 = trunc i32 %61 to i16, !dbg !125
  %63 = load %struct.QueueData*, %struct.QueueData** %8, align 4, !dbg !126
  %64 = bitcast %struct.QueueData* %63 to i8*, !dbg !127
  %65 = call i32 @xTaskCreate(void (i8*)* @QAddTask, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str.1, i32 0, i32 0), i16 zeroext %62, i8* %64, i32 1, i8** %13), !dbg !128
  store i32 %65, i32* %11, align 4, !dbg !129
  %66 = load i32, i32* %11, align 4, !dbg !130
  %67 = icmp ne i32 %66, 1, !dbg !132
  br i1 %67, label %68, label %69, !dbg !133

; <label>:68:                                     ; preds = %46
  call void @printError(), !dbg !134
  br label %69, !dbg !134

; <label>:69:                                     ; preds = %68, %46
  %70 = call i8* @pvPortMalloc(i32 16), !dbg !136
  %71 = bitcast i8* %70 to %struct.QueueData*, !dbg !136
  store %struct.QueueData* %71, %struct.QueueData** %9, align 4, !dbg !137
  %72 = load i8*, i8** %5, align 4, !dbg !138
  %73 = load %struct.QueueData*, %struct.QueueData** %9, align 4, !dbg !139
  %74 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %73, i32 0, i32 0, !dbg !140
  store i8* %72, i8** %74, align 4, !dbg !141
  %75 = load i8*, i8** %6, align 4, !dbg !142
  %76 = load %struct.QueueData*, %struct.QueueData** %9, align 4, !dbg !143
  %77 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %76, i32 0, i32 1, !dbg !144
  store i8* %75, i8** %77, align 4, !dbg !145
  %78 = load i32, i32* %2, align 4, !dbg !146
  %79 = load %struct.QueueData*, %struct.QueueData** %9, align 4, !dbg !147
  %80 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %79, i32 0, i32 2, !dbg !148
  store i32 %78, i32* %80, align 4, !dbg !149
  %81 = load i32, i32* %3, align 4, !dbg !150
  %82 = load %struct.QueueData*, %struct.QueueData** %9, align 4, !dbg !151
  %83 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %82, i32 0, i32 3, !dbg !152
  store i32 %81, i32* %83, align 4, !dbg !153
  %84 = load i32, i32* %1, align 4, !dbg !154
  %85 = trunc i32 %84 to i16, !dbg !154
  %86 = load %struct.QueueData*, %struct.QueueData** %9, align 4, !dbg !155
  %87 = bitcast %struct.QueueData* %86 to i8*, !dbg !156
  %88 = call i32 @xTaskCreate(void (i8*)* @QMultTask, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.2, i32 0, i32 0), i16 zeroext %85, i8* %87, i32 1, i8** %14), !dbg !157
  store i32 %88, i32* %11, align 4, !dbg !158
  %89 = load i32, i32* %11, align 4, !dbg !159
  %90 = icmp ne i32 %89, 1, !dbg !161
  br i1 %90, label %91, label %92, !dbg !162

; <label>:91:                                     ; preds = %69
  call void @printError(), !dbg !163
  br label %92, !dbg !163

; <label>:92:                                     ; preds = %91, %69
  %93 = call i8* @pvPortMalloc(i32 16), !dbg !165
  %94 = bitcast i8* %93 to %struct.QueueData*, !dbg !165
  store %struct.QueueData* %94, %struct.QueueData** %10, align 4, !dbg !166
  %95 = load i8*, i8** %6, align 4, !dbg !167
  %96 = load %struct.QueueData*, %struct.QueueData** %10, align 4, !dbg !168
  %97 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %96, i32 0, i32 0, !dbg !169
  store i8* %95, i8** %97, align 4, !dbg !170
  %98 = load %struct.QueueData*, %struct.QueueData** %10, align 4, !dbg !171
  %99 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %98, i32 0, i32 1, !dbg !172
  store i8* null, i8** %99, align 4, !dbg !173
  %100 = load i32, i32* %2, align 4, !dbg !174
  %101 = load %struct.QueueData*, %struct.QueueData** %10, align 4, !dbg !175
  %102 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %101, i32 0, i32 2, !dbg !176
  store i32 %100, i32* %102, align 4, !dbg !177
  %103 = load i32, i32* %3, align 4, !dbg !178
  %104 = load %struct.QueueData*, %struct.QueueData** %10, align 4, !dbg !179
  %105 = getelementptr inbounds %struct.QueueData, %struct.QueueData* %104, i32 0, i32 3, !dbg !180
  store i32 %103, i32* %105, align 4, !dbg !181
  %106 = load i32, i32* %1, align 4, !dbg !182
  %107 = trunc i32 %106 to i16, !dbg !182
  %108 = load %struct.QueueData*, %struct.QueueData** %10, align 4, !dbg !183
  %109 = bitcast %struct.QueueData* %108 to i8*, !dbg !184
  %110 = call i32 @xTaskCreate(void (i8*)* @QPrintTask, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.3, i32 0, i32 0), i16 zeroext %107, i8* %109, i32 1, i8** %15), !dbg !185
  store i32 %110, i32* %11, align 4, !dbg !186
  %111 = load i32, i32* %11, align 4, !dbg !187
  %112 = icmp ne i32 %111, 1, !dbg !189
  br i1 %112, label %113, label %114, !dbg !190

; <label>:113:                                    ; preds = %92
  call void @printError(), !dbg !191
  br label %114, !dbg !191

; <label>:114:                                    ; preds = %113, %92
  call void @vTaskStartScheduler(), !dbg !193
  ret void, !dbg !194
}

; Function Attrs: nounwind readnone
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

declare !xidane.fname !195 !xidane.function_declaration_type !196 !xidane.function_declaration_filename !197 !xidane.ExternC !27 i8* @xQueueGenericCreate(i32, i32, i8 zeroext) #2

declare !xidane.fname !198 !xidane.function_declaration_type !199 !xidane.function_declaration_filename !200 !xidane.ExternC !27 i8* @pvPortMalloc(i32) #2

declare !xidane.fname !201 !xidane.function_declaration_type !202 !xidane.function_declaration_filename !203 !xidane.ExternC !27 i32 @xTaskCreate(void (i8*)*, i8*, i16 zeroext, i8*, i32, i8**) #2

declare !xidane.fname !204 !xidane.function_declaration_type !205 !xidane.function_declaration_filename !206 !xidane.ExternC !27 void @QStartTask(i8*) #2

; Function Attrs: nounwind
define void @printError() #0 !dbg !207 !xidane.fname !208 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !209 !xidane.ExternC !27 {
  call void (i8*, ...) @xil_printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.4, i32 0, i32 0)), !dbg !210
  ret void, !dbg !211
}

declare !xidane.fname !212 !xidane.function_declaration_type !205 !xidane.function_declaration_filename !206 !xidane.ExternC !27 void @QAddTask(i8*) #2

declare !xidane.fname !213 !xidane.function_declaration_type !205 !xidane.function_declaration_filename !206 !xidane.ExternC !27 void @QMultTask(i8*) #2

declare !xidane.fname !214 !xidane.function_declaration_type !205 !xidane.function_declaration_filename !206 !xidane.ExternC !27 void @QPrintTask(i8*) #2

declare !xidane.fname !215 !xidane.function_declaration_type !25 !xidane.function_declaration_filename !203 !xidane.ExternC !27 void @vTaskStartScheduler() #2

; Function Attrs: nounwind
define void @continualDispatcher(i8*) #0 !dbg !216 !xidane.fname !219 !xidane.function_declaration_type !205 !xidane.function_declaration_filename !26 !xidane.ExternC !27 {
  %2 = alloca i8*, align 4
  store i8* %0, i8** %2, align 4
  call void @llvm.dbg.declare(metadata i8** %2, metadata !220, metadata !30), !dbg !221
  ret void, !dbg !222
}

declare !xidane.fname !223 !xidane.function_declaration_type !224 !xidane.function_declaration_filename !225 !xidane.ExternC !27 void @xil_printf(i8*, ...) #2

attributes #0 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cortex-a9" "target-features"="+dsp,+strict-align,+vfp3,-crypto,-d16,-fp-armv8,-fp-only-sp,-fp16,-neon,-vfp4" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!15, !16, !17, !18}
!llvm.ident = !{!19}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 3.9.0 (tags/RELEASE_390/final)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3)
!1 = !DIFile(filename: "../src/dispatch.c", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!2 = !{}
!3 = !{!4, !5, !10, !13}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 32, align: 32)
!5 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !6, line: 20, baseType: !7)
!6 = !DIFile(filename: "/home/timothyduke/Documents/SDK/2018.2/gnu/aarch32/lin/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include/sys/_stdint.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !8, line: 29, baseType: !9)
!8 = !DIFile(filename: "/home/timothyduke/Documents/SDK/2018.2/gnu/aarch32/lin/gcc-arm-none-eabi/arm-none-eabi/libc/usr/include/machine/_default_types.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!9 = !DIBasicType(name: "unsigned char", size: 8, align: 8, encoding: DW_ATE_unsigned_char)
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "UBaseType_t", file: !11, line: 60, baseType: !12)
!11 = !DIFile(filename: "/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portmacro.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!12 = !DIBasicType(name: "long unsigned int", size: 32, align: 32, encoding: DW_ATE_unsigned)
!13 = !DIDerivedType(tag: DW_TAG_typedef, name: "BaseType_t", file: !11, line: 59, baseType: !14)
!14 = !DIBasicType(name: "long int", size: 32, align: 32, encoding: DW_ATE_signed)
!15 = !{i32 2, !"Dwarf Version", i32 4}
!16 = !{i32 2, !"Debug Info Version", i32 3}
!17 = !{i32 1, !"wchar_size", i32 4}
!18 = !{i32 1, !"min_enum_size", i32 4}
!19 = !{!"clang version 3.9.0 (tags/RELEASE_390/final)"}
!20 = distinct !DISubprogram(name: "dispatchPipeline", scope: !21, file: !21, line: 33, type: !22, isLocal: false, isDefinition: true, scopeLine: 34, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!21 = !DIFile(filename: "/home/timothyduke/workspace/SeniorDesign/src/dispatch.c", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
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
!38 = !DIFile(filename: "/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/queue.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!39 = !DILocation(line: 39, column: 16, scope: !20)
!40 = !DILocalVariable(name: "Queue_2", scope: !20, file: !21, line: 39, type: !37)
!41 = !DILocation(line: 39, column: 25, scope: !20)
!42 = !DILocalVariable(name: "Queue_3", scope: !20, file: !21, line: 39, type: !37)
!43 = !DILocation(line: 39, column: 34, scope: !20)
!44 = !DILocalVariable(name: "Q_Data_1", scope: !20, file: !21, line: 41, type: !45)
!45 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !46, size: 32, align: 32)
!46 = !DIDerivedType(tag: DW_TAG_typedef, name: "QueueData", file: !47, line: 31, baseType: !48)
!47 = !DIFile(filename: "../src/QueueTest.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!48 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "QueueData", file: !47, line: 25, size: 128, align: 32, elements: !49)
!49 = !{!50, !51, !52, !53}
!50 = !DIDerivedType(tag: DW_TAG_member, name: "inputQueue", scope: !48, file: !47, line: 27, baseType: !37, size: 32, align: 32)
!51 = !DIDerivedType(tag: DW_TAG_member, name: "outputQueue", scope: !48, file: !47, line: 28, baseType: !37, size: 32, align: 32, offset: 32)
!52 = !DIDerivedType(tag: DW_TAG_member, name: "queueLength", scope: !48, file: !47, line: 29, baseType: !29, size: 32, align: 32, offset: 64)
!53 = !DIDerivedType(tag: DW_TAG_member, name: "blockSize", scope: !48, file: !47, line: 30, baseType: !29, size: 32, align: 32, offset: 96)
!54 = !DILocation(line: 41, column: 13, scope: !20)
!55 = !DILocalVariable(name: "Q_Data_2", scope: !20, file: !21, line: 41, type: !45)
!56 = !DILocation(line: 41, column: 24, scope: !20)
!57 = !DILocalVariable(name: "Q_Data_3", scope: !20, file: !21, line: 41, type: !45)
!58 = !DILocation(line: 41, column: 35, scope: !20)
!59 = !DILocalVariable(name: "Q_Data_4", scope: !20, file: !21, line: 41, type: !45)
!60 = !DILocation(line: 41, column: 46, scope: !20)
!61 = !DILocalVariable(name: "xReturned", scope: !20, file: !21, line: 43, type: !13)
!62 = !DILocation(line: 43, column: 13, scope: !20)
!63 = !DILocalVariable(name: "xQStartHandle", scope: !20, file: !21, line: 45, type: !64)
!64 = !DIDerivedType(tag: DW_TAG_typedef, name: "TaskHandle_t", file: !65, line: 62, baseType: !4)
!65 = !DIFile(filename: "/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/task.h", directory: "/home/timothyduke/workspace/SeniorDesign/Debug")
!66 = !DILocation(line: 45, column: 15, scope: !20)
!67 = !DILocalVariable(name: "xQAddHandle", scope: !20, file: !21, line: 46, type: !64)
!68 = !DILocation(line: 46, column: 15, scope: !20)
!69 = !DILocalVariable(name: "xQMultHandle", scope: !20, file: !21, line: 47, type: !64)
!70 = !DILocation(line: 47, column: 15, scope: !20)
!71 = !DILocalVariable(name: "xQPrintHandle", scope: !20, file: !21, line: 48, type: !64)
!72 = !DILocation(line: 48, column: 15, scope: !20)
!73 = !DILocation(line: 53, column: 12, scope: !20)
!74 = !DILocation(line: 53, column: 10, scope: !20)
!75 = !DILocation(line: 54, column: 12, scope: !20)
!76 = !DILocation(line: 54, column: 10, scope: !20)
!77 = !DILocation(line: 55, column: 12, scope: !20)
!78 = !DILocation(line: 55, column: 10, scope: !20)
!79 = !DILocation(line: 64, column: 13, scope: !20)
!80 = !DILocation(line: 64, column: 11, scope: !20)
!81 = !DILocation(line: 67, column: 2, scope: !20)
!82 = !DILocation(line: 67, column: 12, scope: !20)
!83 = !DILocation(line: 67, column: 23, scope: !20)
!84 = !DILocation(line: 68, column: 26, scope: !20)
!85 = !DILocation(line: 68, column: 2, scope: !20)
!86 = !DILocation(line: 68, column: 12, scope: !20)
!87 = !DILocation(line: 68, column: 24, scope: !20)
!88 = !DILocation(line: 69, column: 26, scope: !20)
!89 = !DILocation(line: 69, column: 2, scope: !20)
!90 = !DILocation(line: 69, column: 12, scope: !20)
!91 = !DILocation(line: 69, column: 24, scope: !20)
!92 = !DILocation(line: 70, column: 24, scope: !20)
!93 = !DILocation(line: 70, column: 2, scope: !20)
!94 = !DILocation(line: 70, column: 12, scope: !20)
!95 = !DILocation(line: 70, column: 22, scope: !20)
!96 = !DILocation(line: 75, column: 6, scope: !20)
!97 = !DILocation(line: 76, column: 15, scope: !20)
!98 = !DILocation(line: 76, column: 6, scope: !20)
!99 = !DILocation(line: 72, column: 14, scope: !20)
!100 = !DILocation(line: 72, column: 12, scope: !20)
!101 = !DILocation(line: 81, column: 6, scope: !102)
!102 = distinct !DILexicalBlock(scope: !20, file: !21, line: 81, column: 6)
!103 = !DILocation(line: 81, column: 16, scope: !102)
!104 = !DILocation(line: 81, column: 6, scope: !20)
!105 = !DILocation(line: 81, column: 27, scope: !106)
!106 = !DILexicalBlockFile(scope: !102, file: !21, discriminator: 1)
!107 = !DILocation(line: 84, column: 13, scope: !20)
!108 = !DILocation(line: 84, column: 11, scope: !20)
!109 = !DILocation(line: 87, column: 25, scope: !20)
!110 = !DILocation(line: 87, column: 2, scope: !20)
!111 = !DILocation(line: 87, column: 12, scope: !20)
!112 = !DILocation(line: 87, column: 23, scope: !20)
!113 = !DILocation(line: 88, column: 26, scope: !20)
!114 = !DILocation(line: 88, column: 2, scope: !20)
!115 = !DILocation(line: 88, column: 12, scope: !20)
!116 = !DILocation(line: 88, column: 24, scope: !20)
!117 = !DILocation(line: 89, column: 26, scope: !20)
!118 = !DILocation(line: 89, column: 2, scope: !20)
!119 = !DILocation(line: 89, column: 12, scope: !20)
!120 = !DILocation(line: 89, column: 24, scope: !20)
!121 = !DILocation(line: 90, column: 24, scope: !20)
!122 = !DILocation(line: 90, column: 2, scope: !20)
!123 = !DILocation(line: 90, column: 12, scope: !20)
!124 = !DILocation(line: 90, column: 22, scope: !20)
!125 = !DILocation(line: 95, column: 6, scope: !20)
!126 = !DILocation(line: 96, column: 15, scope: !20)
!127 = !DILocation(line: 96, column: 6, scope: !20)
!128 = !DILocation(line: 92, column: 14, scope: !20)
!129 = !DILocation(line: 92, column: 12, scope: !20)
!130 = !DILocation(line: 101, column: 6, scope: !131)
!131 = distinct !DILexicalBlock(scope: !20, file: !21, line: 101, column: 6)
!132 = !DILocation(line: 101, column: 16, scope: !131)
!133 = !DILocation(line: 101, column: 6, scope: !20)
!134 = !DILocation(line: 101, column: 27, scope: !135)
!135 = !DILexicalBlockFile(scope: !131, file: !21, discriminator: 1)
!136 = !DILocation(line: 104, column: 13, scope: !20)
!137 = !DILocation(line: 104, column: 11, scope: !20)
!138 = !DILocation(line: 107, column: 25, scope: !20)
!139 = !DILocation(line: 107, column: 2, scope: !20)
!140 = !DILocation(line: 107, column: 12, scope: !20)
!141 = !DILocation(line: 107, column: 23, scope: !20)
!142 = !DILocation(line: 108, column: 26, scope: !20)
!143 = !DILocation(line: 108, column: 2, scope: !20)
!144 = !DILocation(line: 108, column: 12, scope: !20)
!145 = !DILocation(line: 108, column: 24, scope: !20)
!146 = !DILocation(line: 109, column: 26, scope: !20)
!147 = !DILocation(line: 109, column: 2, scope: !20)
!148 = !DILocation(line: 109, column: 12, scope: !20)
!149 = !DILocation(line: 109, column: 24, scope: !20)
!150 = !DILocation(line: 110, column: 24, scope: !20)
!151 = !DILocation(line: 110, column: 2, scope: !20)
!152 = !DILocation(line: 110, column: 12, scope: !20)
!153 = !DILocation(line: 110, column: 22, scope: !20)
!154 = !DILocation(line: 115, column: 6, scope: !20)
!155 = !DILocation(line: 116, column: 15, scope: !20)
!156 = !DILocation(line: 116, column: 6, scope: !20)
!157 = !DILocation(line: 112, column: 14, scope: !20)
!158 = !DILocation(line: 112, column: 12, scope: !20)
!159 = !DILocation(line: 121, column: 6, scope: !160)
!160 = distinct !DILexicalBlock(scope: !20, file: !21, line: 121, column: 6)
!161 = !DILocation(line: 121, column: 16, scope: !160)
!162 = !DILocation(line: 121, column: 6, scope: !20)
!163 = !DILocation(line: 121, column: 27, scope: !164)
!164 = !DILexicalBlockFile(scope: !160, file: !21, discriminator: 1)
!165 = !DILocation(line: 124, column: 13, scope: !20)
!166 = !DILocation(line: 124, column: 11, scope: !20)
!167 = !DILocation(line: 127, column: 25, scope: !20)
!168 = !DILocation(line: 127, column: 2, scope: !20)
!169 = !DILocation(line: 127, column: 12, scope: !20)
!170 = !DILocation(line: 127, column: 23, scope: !20)
!171 = !DILocation(line: 128, column: 2, scope: !20)
!172 = !DILocation(line: 128, column: 12, scope: !20)
!173 = !DILocation(line: 128, column: 24, scope: !20)
!174 = !DILocation(line: 129, column: 26, scope: !20)
!175 = !DILocation(line: 129, column: 2, scope: !20)
!176 = !DILocation(line: 129, column: 12, scope: !20)
!177 = !DILocation(line: 129, column: 24, scope: !20)
!178 = !DILocation(line: 130, column: 24, scope: !20)
!179 = !DILocation(line: 130, column: 2, scope: !20)
!180 = !DILocation(line: 130, column: 12, scope: !20)
!181 = !DILocation(line: 130, column: 22, scope: !20)
!182 = !DILocation(line: 135, column: 6, scope: !20)
!183 = !DILocation(line: 136, column: 15, scope: !20)
!184 = !DILocation(line: 136, column: 6, scope: !20)
!185 = !DILocation(line: 132, column: 14, scope: !20)
!186 = !DILocation(line: 132, column: 12, scope: !20)
!187 = !DILocation(line: 141, column: 6, scope: !188)
!188 = distinct !DILexicalBlock(scope: !20, file: !21, line: 141, column: 6)
!189 = !DILocation(line: 141, column: 16, scope: !188)
!190 = !DILocation(line: 141, column: 6, scope: !20)
!191 = !DILocation(line: 141, column: 27, scope: !192)
!192 = !DILexicalBlockFile(scope: !188, file: !21, discriminator: 1)
!193 = !DILocation(line: 144, column: 2, scope: !20)
!194 = !DILocation(line: 147, column: 2, scope: !20)
!195 = !{!"xQueueGenericCreate"}
!196 = !{!"QueueHandle_t.const UBaseType_t.0.const UBaseType_t.0.const uint8_t.0"}
!197 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/queue.h"}
!198 = !{!"pvPortMalloc"}
!199 = !{!"void .size_t.0"}
!200 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/portable.h"}
!201 = !{!"xTaskCreate"}
!202 = !{!"BaseType_t.TaskFunction_t.1.const char *const.1.const uint16_t.0.void *const.1.UBaseType_t.0.TaskHandle_t *const.1"}
!203 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/task.h"}
!204 = !{!"QStartTask"}
!205 = !{!"void.void *.1"}
!206 = !{!"../src/QueueTest.h"}
!207 = distinct !DISubprogram(name: "printError", scope: !21, file: !21, line: 161, type: !22, isLocal: false, isDefinition: true, scopeLine: 162, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!208 = !{!"printError"}
!209 = !{!"/home/timothyduke/workspace/SeniorDesign/src/dispatch.c"}
!210 = !DILocation(line: 163, column: 2, scope: !207)
!211 = !DILocation(line: 164, column: 1, scope: !207)
!212 = !{!"QAddTask"}
!213 = !{!"QMultTask"}
!214 = !{!"QPrintTask"}
!215 = !{!"vTaskStartScheduler"}
!216 = distinct !DISubprogram(name: "continualDispatcher", scope: !21, file: !21, line: 155, type: !217, isLocal: false, isDefinition: true, scopeLine: 156, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!217 = !DISubroutineType(types: !218)
!218 = !{null, !4}
!219 = !{!"continualDispatcher"}
!220 = !DILocalVariable(name: "parameter", arg: 1, scope: !216, file: !21, line: 155, type: !4)
!221 = !DILocation(line: 155, column: 34, scope: !216)
!222 = !DILocation(line: 158, column: 2, scope: !216)
!223 = !{!"xil_printf"}
!224 = !{!"void.const char8 *.1"}
!225 = !{!"/home/timothyduke/workspace/Arty_Z7_20/export/Arty_Z7_20/sw/FreeRTOS/FreeRTOS/inc/include_bsp/xil_printf.h"}
