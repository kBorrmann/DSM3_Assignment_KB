# Load libraries
library(shiny)
library(bslib)
library(tidyverse)
library(ggtext)
library(broom)

#Load data
d <- read_delim("report.pg_matrix.tsv") %>% 
  filter(str_detect(pattern = "CON_", string= Protein.Group, negate=T)) %>% 
  select(Protein.Group, Genes, contains("KB")) %>% 
  pivot_longer(-c(Protein.Group, Genes)) %>% 
  drop_na() %>% 
  separate(name, into = c(NA,NA,NA,NA,NA, "concentration", NA, "replicate", "runnumber"), sep = "_") %>% 
  mutate(concentration = if_else(concentration == "0p3", "0.3125",
                                 if_else(concentration == "0p6", "0.625",
                                         if_else(concentration == "1", "1.25",
                                                 if_else(concentration == "2", "2.5", concentration))))) %>% 
  mutate(concentration = factor(concentration, levels = c("0", "0.3125", "0.625", "1.25", "2.5", "5", "10", "20"))) %>% 
  filter(! runnumber %in% c("15013.d", "15014.d", "15015.d", "15371.d", "15372.d", "15373.d"))


p <- read.delim("report.pr_matrix.tsv") %>% 
  filter(str_detect(pattern = "CON_", string= Protein.Group, negate=T)) %>% 
  select(Stripped.Sequence, contains("KB")) %>% 
  pivot_longer(-Stripped.Sequence) %>% 
  drop_na() %>% 
  separate(name, into = c(NA,NA,NA,NA,NA, "concentration", NA, "replicate", "runnumber"), sep = "_") %>% 
  mutate(concentration = if_else(concentration == "0p3", "0.3125",
                                 if_else(concentration == "0p6", "0.625",
                                         if_else(concentration == "1", "1.25",
                                                 if_else(concentration == "2", "2.5", concentration))))) %>% 
  mutate(concentration = factor(concentration, levels = c("0", "0.3125", "0.625", "1.25", "2.5", "5", "10", "20"))) %>% 
  filter(! runnumber %in% c("15013.d", "15014.d", "15015.d", "15371.d", "15372.d", "15373.d"))

#Store intensity plots

barp <- d %>% ggplot(aes(concentration, log10(value), fill = replicate)) +
  geom_col(position = "dodge")+
  labs(x="GSH [mM]", y="log<sub>10</sub>(Intensity)", title="Maximum Intensities Across Samples", fill="Technical Replicate", )+
  theme_bw()+
  theme(axis.title.y = element_markdown())

boxp <- d %>% 
  ggplot(aes(x=replicate, y=log10(value), fill = replicate))+
  geom_boxplot()+
  facet_wrap(.~concentration)+
  labs(x= "Technical Replicates", y= "log<sub>10</sub>(Intensity)", title = "Intensity Distribution")+
  theme_bw()+
  theme(axis.title.y = element_markdown(),
        legend.position = "none",
        text = element_text(size = 18))

denp <- d %>% ggplot(aes(log10(value), fill = replicate))+
  geom_density(alpha = 0.3)+
  facet_wrap(.~concentration)+
  labs(x= "log<sub>10</sub>(Intensity)", y= "Intensity", fill = "Technical Replicates", title = "Intensity Distribution")+
  theme_bw()+
  theme(axis.title.x = element_markdown())

#User interface
ui <- page_sidebar(
  title = "Thermal Proteome Profiling Data",
  sidebar = sidebar(
    selectInput(
      "id",
      label= "Choose which identifications to visualize",
      choices = c("Protein Groups", "Peptides"),
      selected = "Protein Groups"
    ),
    selectInput("intensity",
                label = "Choose a visualzation method",
                choices = c("Bar plot", "Density plot","Box plot"),
                selected = "Bar plot"
    )),
    card(card_header("General information"),
         textInput("partner", label= "Collarboration partners", value = "Enter the names of collaboration partners."
         ),
         textInput("sampleprep", label= "Sample preparation", value = "Who did the sample preparation?"
         ),
         textInput("measurement",label = "Measurements", value = "Who did the measurements?"
         ),
         textInput("data", label  = "Data Analysis", value = "Who did the data analysis?"
         )),
    card(
      card_header("Quality Control"),
      plotOutput("ID"),
      plotOutput("Intensity")
      )
)
# Server 
server <- function(input, output) {
  
  output$Partner <- renderPrint({input$partner})
  
  output$Sampleprep <- renderPrint({input$sampleprep})
  
  output$Measurement <- renderPrint({input$measrement})
  
  output$Data <- renderPrint({input$data})
  
  output$ID <- renderPlot({
    data <- switch(input$id,
                   "Protein Groups" = d,
                   "Peptides" = p)
    axisT <- switch(input$id,
                    "Protein Groups" = "Protein Groups",
                    "Peptides" = "Peptides")
    data %>% 
      ggplot(aes(concentration, fill = replicate))+
      geom_bar(position = "dodge")+
      labs(x="GSH Concentration [mM]",y= axisT, fill= "Technical Replicate", title =  axisT)+
      theme_bw()+
      theme(axis.text.x = element_text(angle = 90))
  })
  
  output$Intensity <- renderPlot({
    int <- switch(input$intensity,
                   "Bar plot" = barp, 
                   "Density plot" = denp,
                   "Box plot" = boxp)
    plot(int)
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
