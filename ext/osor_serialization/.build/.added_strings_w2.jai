// Workspace: Target Program
//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Test
                    inline decode_dynamic_memory(cast(*type_of(T.og))((cast(*u8)element) + 0));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Test
                    inline decode_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 32), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Original_Type
                #assert(size_of(T) == size_of(*Replacement_Type));
                pointer_to_replaced_element : **Replacement_Type = cast(**Replacement_Type)element;
                inline decode_dynamic_memory(pointer_to_replaced_element); 
                <<element = deserialization_replacement(<<pointer_to_replaced_element); 
                    inline decode_dynamic_memory(cast(*type_of(T.data))((cast(*u8)element) + 0));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing string
            dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + element.count); // commit the dynamic allocation

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Table(Key_Type=string, Value_Type=s64, given_hash_function=null, given_compare_function=null, LOAD_FACTOR_PERCENT=70)
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.count))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocated))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.slots_filled))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocator))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.entries))((cast(*u8)element) + 40), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing s64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Allocator
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.proc))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.data))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing s64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing procedure (Allocator_Mode, s64, s64, *void, *void) -> *void

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing *void
            if <<element != null
            {
                log_error("We only allow null-pointers to be serialized, and % wasn't!", T);
                assert(false);
            } // if (<<element) != null

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing float64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] Entry
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing *Replacement_Type
            offset := <<(cast(*u64)element);
            if offset > 0
            {
                <<element = cast(T)(cast(u64)element + <<(cast(*u64)element));
                inline decode_dynamic_memory(<<element); 
            }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] s64
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Entry
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.hash))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.key))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.value))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Replacement_Type
                    inline decode_dynamic_memory(cast(*type_of(T.data_compressed))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.time_of_compression))((cast(*u8)element) + 8));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u32

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 32), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing u8

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] s64
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing string
                memcpy(dynamic_memory_pointer, element.data, element.count);            // copy original data
                element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element); // make pointer, point to the dynamic buffer (encoded)
            dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + element.count); // commit the dynamic allocation

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Table(Key_Type=string, Value_Type=s64, given_hash_function=null, given_compare_function=null, LOAD_FACTOR_PERCENT=70)
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.count))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocated))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.slots_filled))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocator))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.entries))((cast(*u8)element) + 40), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing s64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Apollo_Time
            decode_dynamic_memory(cast(*S128)element);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Allocator
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.proc))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.data))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] Entry
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing S128
                    inline decode_dynamic_memory(cast(*type_of(T.low))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.high))((cast(*u8)element) + 8));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing *void
            if <<element != null
            {
                log_error("We only allow null-pointers to be serialized, and % wasn't!", T);
                assert(false);
            } // if (<<element) != null

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Entry
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.hash))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.key))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.value))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing u64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing procedure (Allocator_Mode, s64, s64, *void, *void) -> *void

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u32

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.variant))((cast(*u8)element) + 40), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.internal))((cast(*u8)element) + 48), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.d))((cast(*u8)element) + 64), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.table))((cast(*u8)element) + 72), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.variant))((cast(*u8)element) + 40), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.internal))((cast(*u8)element) + 48), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.d))((cast(*u8)element) + 64), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.table))((cast(*u8)element) + 72), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [2] float32
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(element.data + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [2] float32
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(element.data + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Table(Key_Type=u32, Value_Type=string, given_hash_function=null, given_compare_function=null, LOAD_FACTOR_PERCENT=70)
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.count))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocated))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.slots_filled))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocator))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.entries))((cast(*u8)element) + 40), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing float32

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing float32

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] Entry
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Table(Key_Type=u32, Value_Type=string, given_hash_function=null, given_compare_function=null, LOAD_FACTOR_PERCENT=70)
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.count))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocated))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.slots_filled))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.allocator))((cast(*u8)element) + 24), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.entries))((cast(*u8)element) + 40), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] Internal_Test
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] Entry
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Entry
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.hash))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.key))((cast(*u8)element) + 4), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.value))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Internal_Test
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 64), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Entry
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.hash))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.key))((cast(*u8)element) + 4), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.value))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] u16
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [3] string
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(element.data + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u16

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [..] float64
                    element.allocated = element.count;
                    element.allocator = Serialized_Data_Allocator;
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing A_Variant
            dynamic_memory_pointer = handle_dynamic_memory(cast(*u64)element, dynamic_memory_pointer, mode, allow_pointer);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] u8
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    memcpy(dynamic_memory_pointer, element.data, array_data_size);           // copy original array elements
                    element.data = xx (cast(u64)dynamic_memory_pointer - cast(u64)element);  // encode the data pointer 
                    data_start := cast(type_of(element.data)) dynamic_memory_pointer;        // get a pointer to the data to iterate
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing float64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u8

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing A_Variant
            dynamic_memory_pointer = handle_dynamic_memory(cast(*u64)element, dynamic_memory_pointer, mode, allow_pointer);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] u8
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] Internal_Test
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u8

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Internal_Test
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 16), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 64), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [3] string
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(element.data + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [..] float64
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing [] u16
                array_data_size := element.count * size_of(type_of(<<element.data)); 
                    data_start := element.data; // if we're not copying we just iterate throught the original data
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + array_data_size); // commit the dynamic allocation
                for 0..element.count-1
                {
                    dynamic_memory_pointer = handle_dynamic_memory(data_start + it, dynamic_memory_pointer, mode); 
                }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing float64

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing u16

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.og))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Test
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.og))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Test
                    inline decode_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 8));
                    inline decode_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 24));
                    inline decode_dynamic_memory(cast(*type_of(T.variant))((cast(*u8)element) + 40));
                    inline decode_dynamic_memory(cast(*type_of(T.internal))((cast(*u8)element) + 48));
                    inline decode_dynamic_memory(cast(*type_of(T.d))((cast(*u8)element) + 64));
                    inline decode_dynamic_memory(cast(*type_of(T.table))((cast(*u8)element) + 72));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [2] float32

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [] u8
                element.data = xx (cast(u64)element + cast(u64)element.data);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Table(Key_Type=u32, Value_Type=string, given_hash_function=null, given_compare_function=null, LOAD_FACTOR_PERCENT=70)
                    inline decode_dynamic_memory(cast(*type_of(T.count))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.allocated))((cast(*u8)element) + 8));
                    inline decode_dynamic_memory(cast(*type_of(T.slots_filled))((cast(*u8)element) + 16));
                    inline decode_dynamic_memory(cast(*type_of(T.allocator))((cast(*u8)element) + 24));
                    inline decode_dynamic_memory(cast(*type_of(T.entries))((cast(*u8)element) + 40));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing A_Variant
            decode_dynamic_memory(cast(*u64)element);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing string
            element.data = cast(*u8)(cast(u64)element + cast(u64)element.data);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Allocator
                    inline decode_dynamic_memory(cast(*type_of(T.proc))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.data))((cast(*u8)element) + 8));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Original_Type
                cleanup_for_serialization(element);
                replaced_element := serialization_replacement(element);
                #assert(size_of(T) == size_of(*Replacement_Type));
                    pointer_to_replaced_element := *replaced_element;
                    dynamic_memory_pointer = handle_dynamic_memory(*pointer_to_replaced_element, dynamic_memory_pointer, mode, allow_pointer = true);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [] Internal_Test
                element.data = xx (cast(u64)element + cast(u64)element.data);
                    for 0..element.count-1
                    {
                        inline decode_dynamic_memory(element.data + it); 
                    }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Original_Type
                replaced_element := serialization_replacement(element);
                #assert(size_of(T) == size_of(*Replacement_Type));
                    <<(cast(**Replacement_Type)element) = *replaced_element;
                    dynamic_memory_pointer = handle_dynamic_memory(cast(**Replacement_Type)element, dynamic_memory_pointer, mode, allow_pointer = true);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [] Entry
                element.data = xx (cast(u64)element + cast(u64)element.data);
                    for 0..element.count-1
                    {
                        inline decode_dynamic_memory(element.data + it); 
                    }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing procedure (Allocator_Mode, s64, s64, *void, *void) -> *void
                <<element = Serialized_Data_Allocator.proc;

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Entry
                    inline decode_dynamic_memory(cast(*type_of(T.hash))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.key))((cast(*u8)element) + 4));
                    inline decode_dynamic_memory(cast(*type_of(T.value))((cast(*u8)element) + 8));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing *Replacement_Type
            if <<element != null
            {
                element_size := size_of(type_of(<<(<<element)));
                    memcpy(dynamic_memory_pointer, <<element, element_size);                      // copy original data
                    <<(cast(*u64)element) = (cast(u64)dynamic_memory_pointer - cast(u64)element); // make pointer, point to the dynamic buffer (encoded)
                    element_data := cast(type_of(<<element)) dynamic_memory_pointer;
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + element_size); // commit the dynamic allocation
                dynamic_memory_pointer = handle_dynamic_memory(element_data, dynamic_memory_pointer, mode); 
            } // if (<<element) != null

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing *void
            offset := <<(cast(*u64)element);
            if offset > 0
            {
                <<element = cast(T)(cast(u64)element + <<(cast(*u64)element));
                inline decode_dynamic_memory(<<element); 
            }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing u32

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Replacement_Type
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.data_compressed))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.time_of_compression))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing void

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Apollo_Time
            dynamic_memory_pointer = handle_dynamic_memory(cast(*S128)element, dynamic_memory_pointer, mode, allow_pointer);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Internal_Test
                    inline decode_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 16));
                    inline decode_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 64));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [] u16
                element.data = xx (cast(u64)element + cast(u64)element.data);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing *Replacement_Type
            if <<element != null
            {
                element_size := size_of(type_of(<<(<<element)));
                    element_data := <<element;
                dynamic_memory_pointer = align_for_serialization(dynamic_memory_pointer + element_size); // commit the dynamic allocation
                dynamic_memory_pointer = handle_dynamic_memory(element_data, dynamic_memory_pointer, mode); 
            } // if (<<element) != null

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [..] float64
                element.allocated = element.count;
                element.allocator = Serialized_Data_Allocator;
                element.data = xx (cast(u64)element + cast(u64)element.data);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [3] string
                    for 0..element.count-1
                    {
                        inline decode_dynamic_memory(element.data + it); 
                    }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Replacement_Type
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.data_compressed))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.time_of_compression))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing S128
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.low))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.high))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing Apollo_Time
            dynamic_memory_pointer = handle_dynamic_memory(cast(*S128)element, dynamic_memory_pointer, mode, allow_pointer);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:75.
//
// Handling dynamic memory for serializing S128
                cleanup_for_serialization(element);
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.low))((cast(*u8)element) + 0), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 
                        dynamic_memory_pointer = handle_dynamic_memory(cast(*type_of(T.high))((cast(*u8)element) + 8), 
                                                                       dynamic_memory_pointer,
                                                                       mode,
                                                                       allow_pointer = false); 

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Test
                    inline decode_dynamic_memory(cast(*type_of(T.a))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.b))((cast(*u8)element) + 16));
                    inline decode_dynamic_memory(cast(*type_of(T.c))((cast(*u8)element) + 32));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [] s64
                element.data = xx (cast(u64)element + cast(u64)element.data);

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Table(Key_Type=string, Value_Type=s64, given_hash_function=null, given_compare_function=null, LOAD_FACTOR_PERCENT=70)
                    inline decode_dynamic_memory(cast(*type_of(T.count))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.allocated))((cast(*u8)element) + 8));
                    inline decode_dynamic_memory(cast(*type_of(T.slots_filled))((cast(*u8)element) + 16));
                    inline decode_dynamic_memory(cast(*type_of(T.allocator))((cast(*u8)element) + 24));
                    inline decode_dynamic_memory(cast(*type_of(T.entries))((cast(*u8)element) + 40));

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing [] Entry
                element.data = xx (cast(u64)element + cast(u64)element.data);
                    for 0..element.count-1
                    {
                        inline decode_dynamic_memory(element.data + it); 
                    }

//
// #insert text. Generated from C:/jai/modules/osor_serialization/../osor_serialization/module.jai:284.
//
// Decoding dynamic memory for deserializing Entry
                    inline decode_dynamic_memory(cast(*type_of(T.hash))((cast(*u8)element) + 0));
                    inline decode_dynamic_memory(cast(*type_of(T.key))((cast(*u8)element) + 8));
                    inline decode_dynamic_memory(cast(*type_of(T.value))((cast(*u8)element) + 24));
