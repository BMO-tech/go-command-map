package main

import "fmt"

func Add(a int, b int) int {
  return a + b
}

func main() {
  fmt.Println("sum is", Add(10, 20))
}
