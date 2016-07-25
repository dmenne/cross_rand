library(Crossover)
library(stringr)

searchCrossOverDesign1 = function(s, p, v, v.rep = NULL, model){
  # eff-factor is badly documented. Just trial/error
  model_i = max(models[model],1)
  eff.factor = c(1, rep(0, model_i-1))
  contrast = "Tukey"
  n = c(3000,20)
  if (is.null(v.rep)) {
    searchCrossOverDesign(s, p, v, model = model,
        contrast = contrast, n = n, eff.factor = eff.factor)
  } else {
    searchCrossOverDesign(s, p, v, model = model,
        contrast = contrast, n = n, v.rep = v.rep, eff.factor = eff.factor)
  }
}


shinyServer(function(input, output, session) {
  disable("computeButton")

  design = reactive({
    input$computeButton

    isolate({
      if (is.na(input$seed)) return(NULL)
      tstring = input$treatments
      if (is.na(tstring) || tstring == "") return(NULL)
      tstring = str_trim(tstring)
      tstring = str_replace_all(tstring, " *: *",":")
      treats = str_split(tstring, " +")[[1]]
      validate(
        need(nchar(
          as.character(input$seed)) > 4, "Please enter a 5 digit random seed number"),
        need(input$seed <= 99999, "Random number too long"),
        need(input$study, "Please enter name of study"),
        need(length(treats) > 1, "At least 2 treatments are required")
      )
      n_treat = length(treats)
      n_days = input$n_days
      n_subjects = input$n_subjects
      set.seed(input$seed)
      study = input$study
    })
    treats1 = str_split(treats,":")
    treats = sapply(treats1,"[",1)
    weights = as.integer(sapply(treats1,"[",2))
    use_weights = !(any(is.na(weights)))
    use_weights = use_weights && sum(weights) == n_subjects*n_days
    v.rep = NULL
    if (use_weights) v.rep = weights
    des = searchCrossOverDesign1(n_subjects, n_days, n_treat, v.rep, input$model)
    d = as.data.frame(matrix(treats[t(getDesign(des))],nrow = n_subjects))
    d = setNames(d, paste("Visit", 1:n_days)) #
    cap = table(unlist(d))
    cap = cap[order(names(cap))]
    cap = paste0("<h2>Summary: Study ", study, "</h2><ul><li>",
                 "Weights were ", c("<b>NOT</b>","")[use_weights + 1], " used.</li>\n<li>",
                 n_treat, " treatments</li>\n<li>",
                 n_days, " study days</li>\n<li>",
                 n_subjects, " patients.</li>\n<li>",
                paste(names(cap), ": ", cap, sep = " ", collapse = " records</li>\n<li>"),
                " records</li>\n</ul>Please forward the summary (not the table) to your study manager.")
    d = cbind(RandID = 1:nrow(d), d)
    list(d = d, cap = cap)
  })

  output$caption = renderUI(HTML(design()$cap))
  output$table = renderTable(design()$d, include.rownames = FALSE)

  observe({
    valid_study = !is.na(input$study) && nchar(input$study) >3
    valid_seed = !is.na(input$seed) && input$seed > 10000

    tstring = input$treatments
    valid_treats = !is.na(tstring) && tstring != "" &&
      length(str_split(tstring, " ")[[1]]) >1
    toggleState("computeButton", valid_study && valid_seed && valid_treats)
  })
})

