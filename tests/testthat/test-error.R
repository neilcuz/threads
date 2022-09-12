
test_that("sse calculations work", {
  
  expect_equal(error(4, 2, method = "sse"), sse(4, 2))
  
  expect_equal(error(c(1, 2, 3), c(2, 3, 4), method = "sse"), 
               sse(c(1, 2, 3), c(2, 3, 4)))
  
})

test_that("sse calculations work", {
  
  expect_equal(error(20, 15, method = "mape"), mape(20, 15))
  expect_equal(error(c(15, 10, 15), c(20, 5, 25), method = "mape"), 
               mape(c(15, 10, 15), c(20, 5, 25)))
  
})

test_that("numbers passed as text gives an error", {
  
  expect_error(error("4", 2), method = "sse")
  expect_error(error("4", 2), method = "mape")
  expect_error(error(4, "2"), method = "sse")
  expect_error(error(2, "2"), method = "mape")
  
})
