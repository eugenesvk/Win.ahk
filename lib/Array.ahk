#Requires AutoHotKey 2.0.10

HasValue(haystack, needle) { ; Checks if a value exists in an array
  ;FoundPos := HasValue(Haystack, Needle)
  if !(IsObject(haystack)) {
    return -1
    ; throw ValueError("Bad haystack!", -1, haystack)
  }
  for index, value in haystack
    if (value = needle)
      return index
  return 0
}

; autohotkey.com/boards/viewtopic.php?p=537511#p537526
Array.Prototype.DefineProp("ForEach", {call:_ArrayForEach})
_ArrayForEach(this, func) { ; Applies a function to each key/value pair in the Array
  ; @param   func callback function with arguments Callback(value[, key, array])
  ; @returns {Array}
  if not HasMethod(func) {
    throw ValueError("ForEach: func must be a function", -1)
  } else {
    for i, v in this {
      func(v, i, this)
    }
    return this
  }
}

joinArr(arrays*) {
  outArr := []
  for i,arr in arrays {
    if not type(arr) = 'Array' {
      throw ValueError('Argument #' i ' is not an array!', -1)
    }
    for el in arr {
      outArr.Push(el)
    }
  }
  return outArr
}
