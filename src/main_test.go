package main

import "testing"

func TestAdd(t *testing.T) {
  num1 := 10
  num2 := 15
  sum := 25
  res := Add(num1, num2)
  if res != sum {
    t.Error("Expected ", sum, " got ", res)
  }
}
