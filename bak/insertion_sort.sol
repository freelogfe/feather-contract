pragma solidity ^0.4.19;
library InsertionSort {
  uint swap;
  function isort(uint [] list){
    for (uint i = 1; i < list.length; i++){
      for (uint j = i; (j > 0) && (list[j]< list[j-1]); j--){
        swap = list[j-1];
        list[j-1] = list[j];
        list[j] = swap;
      }
    }
  }

  return list;
}
