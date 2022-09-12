
test_that("basic calculations work", {
  
  expect_equal(sse(4, 2), 4)
  expect_equal(sse(c(1, 2, 3), c(2, 3, 4)), 3)
  
})


test_that("numbers passed as text gives an error", {
  
  expect_error(sse("4", 2))
  expect_error(see(4, "2"))
  
})
