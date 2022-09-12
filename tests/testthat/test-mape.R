
test_that("basic calculations work", {
  
  expect_equal(mape(20, 15), 0.25)
  expect_equal(mape(c(15, 10, 15), c(20, 5, 25)), 0.5)
  
})


test_that("numbers passed as text gives an error", {
  
  expect_error(sse("20", 15))
  expect_error(see(20, "15"))
  
})