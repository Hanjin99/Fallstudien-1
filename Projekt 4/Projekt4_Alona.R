library(readxl)
library(ggplot2)

df <- read_xlsx("Medaillen.xlsx")
head(df)
str(df)

summary(df)
#keine NA-Werte

attach(df)
#Deskriptive Analyse
par(mar = c(4.2, 4, 1, 1), mfrow = c(2, 2))
barplot(table(NrGold), main = "", ylab = "Anzahl", xlab = "NrGold", 
        cex.axis = 1.1, cex.lab = 1.3) 
barplot(table(NrSilber), main = "", ylab = "Anzahl", xlab = "NrSilber",
        cex.axis = 1.1, cex.lab = 1.3)
barplot(table(NrBronze), main = "", ylab = "Anzahl", xlab = "NrBronze",
        cex.axis = 1.1, cex.lab = 1.3)
barplot(table(Total), main = "", ylab = "Anzahl", xlab = "Total",
        cex.axis = 1.1, cex.lab = 1.3)

#1
# Abhängigkeit zwischen dem Land und der Sportart bezüglich der Gesamtanzahl an Medaillen
ggplot(df, aes(x = Land, y = Total, fill = Sportart)) +
  geom_bar(stat = "identity") + 
  scale_fill_manual(values = c("orange", "lightgreen", "purple", "lightblue")) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),  
        axis.text.y = element_text(size = 14),                        
        axis.title = element_text(size = 16))                         

# Erstellen der Kontingenztafel
kontingenztafel1 <- xtabs(Total ~ Land + Sportart, data = df)
kontingenztafel1
# Chi-Quadrat-Test
# Um zu prüfen, ob es eine statistisch signifikante Abhängigkeit 
# zwischen Land und Sportart bezüglich Total gibt
chisq.test(kontingenztafel1)
# p-value = 4.189e-14 < 0.05 deutet auf signifikante Abhänigkeit hin

#2
# Abhängigkeit zwischen der Medaillenfarbe und dem Land für jede Sportart

# Fisher's Exakter Test für jede Sportart
for (sport in unique(df$Sportart)) {
  subset_data <- subset(df, sport == Sportart)
  
  # Erstellen einer Kontingenztafel der Medaillenfarben für jedes Land
  medaillen_matrix <- xtabs(cbind(NrGold, NrSilber, NrBronze) ~ Land, data = subset_data)
  
  fisher_test <- fisher.test(medaillen_matrix)
  
  print(paste("Fisher's Exakter Test für Sportart:", sport))
  print(fisher_test)
}
# Kampfsport: p-value = 0.2997 > 0.05
# Leichtathletik: p-value = 0.5348 > 0.05
# Ballsportart: p-value = 0.02756 < 0.05 => signifikante Zusammenhang zwischen 
# dem Land und der Medaillenfarbe in der Kategorie der Ballsportarten
# Schwimmen: p-value = 0.2549 > 0.05

# Erstellen der Daten im Langformat
df_long <- data.frame(
  Land = rep(Land, 3),
  Sportart = rep(Sportart, 3),
  Medaille = factor(rep(c("Gold", "Silber", "Bronze"), each = nrow(df))),
  Anzahl = c(df$NrGold, df$NrSilber, df$NrBronze)
)

# Medaillenverteilung nach Land und Sportart
ggplot(df_long, aes(x = Land, y = Anzahl, fill = Medaille)) +
  geom_bar(position = "stack", stat = "identity") +
  facet_wrap(~ Sportart) +
  scale_fill_manual(values = c("Gold" = "gold", "Silber" = "#C0C0C0", "Bronze" = "#CD7F32")) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "Land", y = "Anzahl Medaillen", fill = "Medaille")

#3
# Abhängigkeit zwischen der Medaillenfarbe und der Sportart für jedes Land         
# Fisher's Exakter Test für jedes Land
for (land in unique(df$Land)) {
  subset_data <- subset(df, land == Land)
  
  # Erstellen einer Kontingenztafel der Medaillenfarben für jedes Land
  medaillen_matrix <- xtabs(cbind(NrGold, NrSilber, NrBronze) ~ Sportart, data = subset_data)
  
  fisher_test <- fisher.test(medaillen_matrix)
  
  print(paste("Fisher's Exakter Test für Land:", land))
  print(fisher_test)
}
# USA: p-value = 0.3431 > 0.05
# VR China: p-value = 0.03666 < 0.05 => signifikante Zusammenhang zwischen 
# der Sportart und der Medaillenfarbe in VR China
# Japan: p-value = 0.04942 < 0.05 => signifikante Zusammenhang zwischen 
# der Sportart und der Medaillenfarbe in Japan
# Australien: p-value = 0.1837 > 0.05
# Frankreich: p-value = 0.2334 > 0.05