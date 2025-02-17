# Laden der notwendigen Pakete
library(pROC) # ROC-Kurvenanalyse und AUC-Berechnung
library(caret) # Kreuzvalidierung und Vergleich von Modellen

df <- read.csv("US_election_2024.csv", sep = ";", dec = ",")
head(df)
str(df)

dim(df)
#51 11

summary(df)
#keine NA Werte

#Deskriptive Analyse

table(df$State)
#Eine Beobachung aus jedem Staat

table(df$Leading_Candidate)
# Harris  Trump 
# 20     31 

#Statistische Kennwerte für kardinal stetig skalierte Variablen
num_stat <- function(data) {
  var_name <- variable.names(df[3:10])
  result <- matrix(NA, nrow = length(data), ncol = 8)
  colnames(result) <- c("Merkmal", "min", "q0.25", "q0.5", 
                        "Arith. Mittel", "q0.75", "max", "sd")
  for(i in 1:length(data)) {
    var_data <- data[[i]]
    
    q1 <- quantile(var_data, 0.25, type = 2)
    q3 <- quantile(var_data, 0.75, type = 2)
    
    result[i, 1] <- var_name[i]
    result[i, 2] <- sprintf("%.3f", min(var_data))
    result[i, 3] <- sprintf("%.3f", q1)
    result[i, 4] <- sprintf("%.3f", median(var_data))
    result[i, 5] <- sprintf("%.3f", mean(var_data))
    result[i, 6] <- sprintf("%.3f", q3)
    result[i, 7] <- sprintf("%.3f", max(var_data))
    result[i, 8] <- sprintf("%.3f", sd(var_data))
  } 
  return(as.data.frame(result))
}
num_stat(df[,3:10])

# Datenaufbereitung
df$Total_Area <- log(df$Total_Area)
print(df$Total_Area)
hist(df$Total_Area)

df$Population <- log(df$Population)
print(df$Population)
hist(df$Population)

df$Population_Density <- log(df$Population_Density)
print(df$Population_Density)
hist(df$Population_Density)

################################################################################

# Aufgabe 1 - die Zielvariable Leading_Candidate modellieren
# Harris = 0, Trump = 1 kodieren (da wir Logistische Regression verwenden, 
# muss die Zielvariable numerisch sein und als 0 und 1 kodiert werden)
df$Leading_Candidate <- ifelse(df$Leading_Candidate == "Harris", 0, 1)
df$Leading_Candidate <- as.factor(df$Leading_Candidate)

# Logistische Regression
Modell_voll <- glm(df$Leading_Candidate ~ df$Total_Area + df$Population
                   + df$Median_Age + df$Birth_Rate + df$HDI + df$Unemployment_Rate + df$Median_Rent
                   + df$Health_Insurance_Coverage, family = binomial)

# Ergebnisse anzeigen
summary(Modell_voll)

# Call:
#   glm(formula = df$Leading_Candidate ~ df$Total_Area + df$Population + 
#         df$Median_Age + df$Birth_Rate + df$HDI + df$Unemployment_Rate + 
#         df$Median_Rent + df$Health_Insurance_Coverage, family = binomial)
# 
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)
# (Intercept)                   1.325e+02  8.332e+01   1.590    0.112
# df$Total_Area                 1.060e+00  1.495e+00   0.709    0.478
# df$Population                 1.667e+00  1.071e+00   1.557    0.119
# df$Median_Age                -2.686e-01  5.962e-01  -0.450    0.652
# df$Birth_Rate                 5.353e-02  2.768e-01   0.193    0.847
# df$HDI                       -6.299e+01  6.179e+01  -1.019    0.308
# df$Unemployment_Rate         -2.392e+02  1.733e+02  -1.381    0.167
# df$Median_Rent               -7.343e-03  5.643e-03  -1.301    0.193
# df$Health_Insurance_Coverage -9.046e+01  6.638e+01  -1.363    0.173
# 
# (Dispersion parameter for binomial family taken to be 1)
# 
# Null deviance: 68.310  on 50  degrees of freedom
# Residual deviance: 16.198  on 42  degrees of freedom
# AIC: 34.198
# 
# Number of Fisher Scoring iterations: 8

################################################################################
# Aufgabe 2

# Schrittweise Selektion basierend auf AIC
# Durchführung der Schrittweisen Selektion (beide Richtungen)
Modell_reduziert <- step(Modell_voll, direction = "both", trace = 0)

# Zusammenfassung des ausgewählten Modells
summary(Modell_reduziert)

# Call:
#   glm(formula = df$Leading_Candidate ~ df$Population + df$Median_Age + 
#         df$Unemployment_Rate + df$Median_Rent + df$Health_Insurance_Coverage, 
#       family = binomial)
# 
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)   
# (Intercept)                   1.431e+02  5.250e+01   2.725  0.00642 **
# df$Population                 1.672e+00  9.192e-01   1.819  0.06887 . 
# df$Median_Age                -3.783e-01  2.961e-01  -1.278  0.20129   
# df$Unemployment_Rate         -1.818e+02  1.274e+02  -1.427  0.15345   
# df$Median_Rent               -1.163e-02  4.348e-03  -2.676  0.00745 **
# df$Health_Insurance_Coverage -1.404e+02  5.540e+01  -2.534  0.01126 * 
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# (Dispersion parameter for binomial family taken to be 1)
# 
# Null deviance: 68.310  on 50  degrees of freedom
# Residual deviance: 17.524  on 45  degrees of freedom
# AIC: 29.524
# 
# Number of Fisher Scoring iterations: 8

# Konfidenzintervalle der Koeffizienten
confint.default(Modell_reduziert)
#                                       2.5 %        97.5 %
#  (Intercept)                    40.18578546 245.969897615
#  df$Population                  -0.12929658   3.473717303
#  df$Median_Age                  -0.95863441   0.201945736
#  df$Unemployment_Rate         -431.53963693  67.841629156
#  df$Median_Rent                 -0.02015508  -0.003113086
#  df$Health_Insurance_Coverage -248.97290664 -31.820859017

# Vergleich der Modelle anhand von AIC
cat("AIC des vollständigen Modells:", AIC(Modell_voll), "\n")
# AIC des vollständigen Modells: 34.19821 

cat("AIC des reduzierten Modells:", AIC(Modell_reduziert), "\n")
# AIC des reduzierten Modells: 29.5241 

###############################################################################
#Aufgabe 3
set.seed(123456)
levels(df$Leading_Candidate) <- c("Harris", "Trump")

# Alle erklärenden Variablen
formula_full <- Leading_Candidate ~ Total_Area + Population +
  Median_Age + Birth_Rate + HDI + Unemployment_Rate +
  Median_Rent + Health_Insurance_Coverage

# Reduziertes Modell (basierend auf stepwise AIC)
formula_reduced <- Leading_Candidate ~ Population + Median_Age +
  Unemployment_Rate + Median_Rent + Health_Insurance_Coverage

# TrainControl für die Kreuzvalidierung mit ROC und AUC
train_control <- trainControl(
  method = "cv",          # 10-fache Kreuzvalidierung
  number = 10,            # Anzahl der Folds
  classProbs = TRUE,      # Berechnung der Klassenwahrscheinlichkeiten
  summaryFunction = twoClassSummary,
  savePredictions = "final" # Berechnung von ROC und AUC
)

# Vollständiges Modell (Modell mit allen Variablen)
cv_full_model <- train(
  formula_full,
  data = df,
  method = "glm",
  family = "binomial",
  trControl = train_control,
  metric = "ROC" # Optimierung basierend auf ROC
)

# Reduziertes Modell (Modell mit ausgewählten Variablen)
cv_reduced_model <- train(
  formula_reduced,
  data = df,
  method = "glm",
  family = "binomial",
  trControl = train_control,
  metric = "ROC"
)

# Vorhersagen für die ROC-Kurven erstellen
pred_full <- predict(cv_full_model$finalModel, newdata = df, type = "response")
pred_reduced <- predict(cv_reduced_model$finalModel, newdata = df, type = "response")

# ROC-Kurven berechnen
roc_full <- roc(df$Leading_Candidate, pred_full)
roc_reduced <- roc(df$Leading_Candidate, pred_reduced)

# AUC-Werte berechnen
auc_full <- auc(roc_full)
auc_reduced <- auc(roc_reduced)

# ROC-Kurven visualisieren
plot(roc_full, col = "blue", lwd = 2, main = "ROC-Kurven: Vollständig vs. Reduziert")
lines(roc_reduced, col = "red", lwd = 2)
legend("bottomright", legend = c(paste("Vollständig (AUC =", round(auc_full, 2), ")"),
                                 paste("Reduziert (AUC =", round(auc_reduced, 2), ")")),
       col = c("blue", "red"), lwd = 2)

# AUC-Werte ausgeben
cat("AUC des vollständigen Modells:", auc_full, "\n")
cat("AUC des reduzierten Modells:", auc_reduced, "\n")

# Ergebnisse der Kreuzvalidierung
cat("ROC aus der Kreuzvalidierung (vollständig):", max(cv_full_model$results$ROC), "\n")
cat("ROC aus der Kreuzvalidierung (reduziert):", max(cv_reduced_model$results$ROC), "\n")
