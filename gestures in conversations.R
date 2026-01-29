library(tidyverse)
library(dplyr)
library(wesanderson)
library(ggplot2)
library(umap)

data <- read.csv("data.csv", sep = ";")
data[data == ""] <- NA

# Prepare child data with ID
child_long <- data %>%
  select(CID, child.hand, child.head, child.body, child_gesture.type) %>%
  pivot_longer(cols = c(child.hand, child.head, child.body),
               names_to = "body_part_raw", values_to = "used") %>%
  filter(!is.na(used), !is.na(child_gesture.type)) %>%
  mutate(
    speaker = "Child",
    ID = CID,
    gesture_type = child_gesture.type,
    body_part = str_replace(body_part_raw, "child.", "")
  ) %>%
  select(speaker, ID, body_part, gesture_type)

# Prepare adult data with ID
adult_long <- data %>%
  select(AID, adult.hand, adult.head, adult.body, adult_gesture.type) %>%
  pivot_longer(cols = c(adult.hand, adult.head, adult.body),
               names_to = "body_part_raw", values_to = "used") %>%
  filter(!is.na(used), !is.na(adult_gesture.type)) %>%
  mutate(
    speaker = "Adult",
    ID = AID,
    gesture_type = adult_gesture.type,
    body_part = str_replace(body_part_raw, "adult.", "")
  ) %>%
  select(speaker, ID, body_part, gesture_type)

# Combine child and adult data
combined_data <- bind_rows(child_long, adult_long)


# Count gestures
gesture_counts <- combined_data %>%
  group_by(speaker, ID, body_part, gesture_type) %>%
  summarise(count = n(), .groups = 'drop')

# Total gestures per person
total_counts <- gesture_counts %>%
  group_by(speaker, ID) %>%
  summarise(total = sum(count), .groups = "drop")

# Compute individual proportions
gesture_props <- gesture_counts %>%
  left_join(total_counts, by = c("speaker", "ID")) %>%
  mutate(proportion = count / total)

# Mean and SE per speaker group
mean_props <- gesture_props %>%
  group_by(speaker, gesture_type, body_parts) %>%
  summarise(
    mean_prop = mean(proportion),
    se_prop = sd(proportion) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

#bar plots with mean, error bar and individual points of proportion of gestures

ggplot(mean_props, aes(x = gesture_type, y = mean_prop, fill = speaker)) +
  geom_bar(stat = "identity", width = 0.7, position = position_dodge(0.8)) +
  geom_errorbar(aes(ymin = mean_prop - se_prop, ymax = mean_prop + se_prop),
                width = 0.2, linewidth = 0.5, position=position_dodge(0.8)) +
  #geom_jitter(data = gesture_props,
  #aes(x = body_part, y = proportion, shape = ID),
  #position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.8),
  #color = "black", size = 2, inherit.aes = FALSE) +
  scale_shape_manual(values = 1:12)+
  scale_y_continuous(limits = c(0,0.5))+
  scale_x_discrete(labels= c("Conventional", "Deictic", "Iconic", "Non-referential"))+
  #facet_wrap(~speaker, scales = "free_x") +
  labs(
    x = "Gesture type",
    y = "Mean proportion of gesture type"
  ) +
  scale_fill_manual(values=wes_palette(n = 4, name = "Royal2"), labels=c("Adult", "Child"))+
  theme(
    legend.key.size = unit(0.6, "cm"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    strip.background = element_rect(fill = "lightgray", color = "black", linewidth = 1), # Facet label background and border
    strip.text = element_text(color = "black", size = 12, face = "bold"), # Facet label text styling
    axis.line = element_line(colour = "black"),  # Add borders for axes
    axis.title.y = element_text(size = 15, vjust = 1.5, margin = unit(c(0, 5, 0, 0), "mm")),
    axis.title.x = element_text(size = 15, vjust = 1.5, margin = unit(c(5, 0, 0, 0), "mm")),
    axis.text.x = element_text(color = "black", size = 12),
    axis.text.y = element_text(color = "black", size = 12),
    legend.title = element_blank(),
    legend.position = "top", 
    legend.justification = "left", 
    legend.direction = "vertical",
    plot.margin = margin(50, 50, 50, 50)
  )


#heat map with gesture and body part used
ggplot(mean_props, aes(x = body_part, y = gesture_type, fill = mean_prop)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightgreen", high = "darkgreen") +
  facet_wrap(~speaker) +
  scale_y_discrete(labels = c(
    "CO" = "Conventional",
    "I" = "Iconic",
    "D" = "Deictic",
    "NR" = "Non-referential"
  )) +
  labs(
    x = "Body part used",
    y = "Mean proportion of gesture type",
    fill = "Mean Proportion"
  ) +
  theme(
    legend.key.size = unit(0.6, "cm"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    strip.background = element_rect(fill = "lightgray", color = "black", linewidth = 1), # Facet label background and border
    strip.text = element_text(color = "black", size = 12, face = "bold"), # Facet label text styling
    axis.line = element_line(colour = "black"),  # Add borders for axes
    axis.title.y = element_text(size = 15, vjust = 1.5, margin = unit(c(0, 5, 0, 0), "mm")),
    axis.title.x = element_text(size = 15, vjust = 1.5, margin = unit(c(5, 0, 0, 0), "mm")),
    axis.text.x = element_text(color = "black", size = 10),
    axis.text.y = element_text(color = "black", size = 10),
    legend.title = element_blank(),
    legend.position = "left", 
    legend.justification = "left", 
    legend.direction = "vertical",
    plot.margin = margin(50, 100, 100, 50)
  )


#heat map with gesture and speech

child_long_speech <- data %>%
  select(child_gesture.type, child_speech) %>%
  filter(!is.na(child_gesture.type), !is.na(child_speech)) %>%
  mutate(speaker = "Child",
         gesture_type = child_gesture.type,
         speech = child_speech) %>%
  select(speaker, gesture_type, speech)

adult_long_speech <- data %>%
  select(adult_gesture.type, adult_speech) %>%
  filter(!is.na(adult_gesture.type), !is.na(adult_speech)) %>%
  mutate(speaker = "Adult",
         gesture_type = adult_gesture.type,
         speech = adult_speech) %>%
  select(speaker, gesture_type, speech)

combined_speech <- bind_rows(child_long_speech, adult_long_speech)

gesture_speech_counts <- combined_speech %>%
  group_by(speaker, gesture_type, speech) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(speaker, gesture_type) %>%  # Group by gesture type within each speaker
  mutate(proportion = count / sum(count)) %>%
  ungroup()

mean_gestures <- gesture_speech_counts %>%
  group_by(speaker, gesture_type, speech) %>%
  summarise(
    mean_proportion = mean(proportion),
    se_proportion = sd(proportion) / sqrt(n()),
    .groups = "drop"
  )
#heatmap of gesture type with vocal modality 
ggplot(mean_gestures, aes(x = speech , y = gesture_type, fill = mean_proportion)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightblue", high = "steelblue") +
  facet_wrap(~speaker) +
  labs(
    x = "Vocal modality categories",
    y = "Mean proportion of gesture type",
    fill = "Proportion"
  ) +
  scale_y_discrete (labels = c(
    "CO" = "Conventional",
    "I" = "Iconic",
    "D" = "Deictic",
    "NR" = "Non-referential"
  )) +
  theme(
    legend.key.size = unit(0.6, "cm"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    strip.background = element_rect(fill = "lightgray", color = "black", size = 1), # Facet label background and border
    strip.text = element_text(color = "black", size = 12, face = "bold"), # Facet label text styling
    axis.line = element_line(colour = "black"),  # Add borders for axes
    axis.title.y = element_text(size = 15, vjust = 1.5, margin = unit(c(0, 5, 0, 0), "mm")),
    axis.title.x = element_text(size = 15, vjust = 1.5, margin = unit(c(5, 0, 0, 0), "mm")),
    axis.text.x = element_text(color = "black", size = 10),
    axis.text.y = element_text(color = "black", size = 10),
    legend.title = element_blank(),
    legend.position = "left", 
    legend.justification = "left", 
    legend.direction = "vertical",
    plot.margin = margin(100, 100, 100, 100)
  )



##########
#UMAP clustering with gesture type and speech
########@

# Prepare child data
child_df <- data %>%
  select(child_gesture.type, child_speech) %>%
  rename(gesture = child_gesture.type, speech = child_speech) %>%
  mutate(speaker = "Child")

# Prepare adult data
adult_df <- data %>%
  select(adult_gesture.type, adult_speech) %>%
  rename(gesture = adult_gesture.type, speech = adult_speech) %>%
  mutate(speaker = "Adult")

# Combine
combined_df <- bind_rows(child_df, adult_df) %>%
  filter(!is.na(gesture), !is.na(speech))

# One-hot encode
gesture_encoded <- model.matrix(~ gesture - 1, combined_df)
speech_encoded <- model.matrix(~ speech - 1, combined_df)
umap_input <- as.data.frame(cbind(gesture_encoded, speech_encoded))

# UMAP
umap_result <- umap(umap_input)
umap_coords <- as.data.frame(umap_result$layout)

# Add metadata
umap_coords$gesture <- combined_df$gesture
umap_coords$speech <- combined_df$speech
umap_coords$speaker <- combined_df$speaker

# Slightly shift adult data for visual separation
umap_coords <- umap_coords %>%
  mutate(
    V1 = ifelse(speaker == "Adult", V1 + 2, V1),
    alpha = ifelse(speaker == "Adult", 1.0, 0.4)
  )

# Define color and shape mappings
gesture_levels <- unique(umap_coords$gesture)
speech_levels <- unique(umap_coords$speech)

gesture_colors <- setNames(
  brewer.pal(min(length(gesture_levels), 12), "Set1"),
  gesture_levels
)

distinct_shapes <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 15, 16, 17, 18, 19)

# Assign them to the speech categories
speech_shapes <- setNames(
  distinct_shapes[seq_along(speech_levels)],
  speech_levels
)

# Plot
ggplot(umap_coords, aes(x = V1, y = V2, color = gesture, shape = speech)) +
  geom_point(aes(alpha = 0.8), size = 2, position = position_jitter(width = 5, height = 0.2), stroke = 1) +  # Increase size and jitter for clarity
  scale_color_manual(values = gesture_colors, labels= c("Conventional", "Deictic", "Iconic", "Non-referential")) +   # Apply speech_colors
  scale_shape_manual(values = speech_shapes) +  # Apply gesture shapes
  scale_alpha_identity() +
  labs(
    x = "UMAP 1", y = "UMAP 2",
    color = "Gesture Type",
    shape = "Speech category"
  ) +
  facet_wrap(~speaker) +  # Facet by speaker
  theme_minimal() +
  theme(
    legend.key.size = unit(0.6, "cm"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    strip.background = element_rect(fill = "lightgray", color = "black", size = 1), # Facet label background and border
    strip.text = element_text(color = "black", size = 12, face = "bold"), # Facet label text styling
    axis.line = element_line(colour = "black"),  # Add borders for axes
    axis.title.y = element_text(size = 15, vjust = 1.5, margin = unit(c(0, 5, 0, 0), "mm")),
    axis.title.x = element_text(size = 15, vjust = 1.5, margin = unit(c(5, 0, 0, 0), "mm")),
    axis.text.x = element_text(color = "black", size = 10),
    axis.text.y = element_text(color = "black", size = 10),
    legend.title = element_blank(),
    legend.position = "right", 
    legend.justification = "left", 
    legend.direction = "vertical",
    #plot.margin = margin(100, 100, 100, 100),
    panel.border = element_rect(color = "black", fill = NA, size = 1)
  )


#############
#proportion of gesture types by child-parent pairs
############

# Prepare child data
child_gestures <- data %>%
  filter(!is.na(child_gesture.type) & child_gesture.type != "") %>%
  group_by(CID, child_gesture.type) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(CID) %>%
  mutate(proportion = count / sum(count),
         role = "Child") %>%
  rename(ID = CID, gesture_type = child_gesture.type)

# Prepare adult data
adult_gestures <- data %>%
  filter(!is.na(adult_gesture.type) & adult_gesture.type != "") %>%
  group_by(AID, adult_gesture.type) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(AID) %>%
  mutate(proportion = count / sum(count),
         role = "Adult") %>%
  rename(ID = AID, gesture_type = adult_gesture.type)

# Combine both
all_gestures <- bind_rows(child_gestures, adult_gestures)

# Plot
ggplot(all_gestures, aes(x = ID, y = proportion, fill = gesture_type)) +
  geom_bar(stat = "identity", color = "black", width = 0.4) +
  facet_wrap(~ role, ncol = 1, scales = "free_x") +
  scale_fill_manual(values=wes_palette(n = 4, name = "Royal2"), labels=c("Conventional", "Deictic", "Iconic", "Non-referential"))+
  labs(
    x = "Individual ID", y = "Proportion of gesture type", fill = "Gesture Type") +
  theme(
    legend.key.size = unit(0.6, "cm"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    strip.background = element_rect(fill = "lightgray", color = "black", size = 1), # Facet label background and border
    strip.text = element_text(color = "black", size = 12, face = "bold"), # Facet label text styling
    axis.line = element_line(colour = "black"),  # Add borders for axes
    axis.title.y = element_text(size = 15, vjust = 1.5, margin = unit(c(0, 5, 0, 0), "mm")),
    axis.title.x = element_text(size = 15, vjust = 1.5, margin = unit(c(5, 0, 0, 0), "mm")),
    axis.text.x = element_text(color = "black", size = 10),
    axis.text.y = element_text(color = "black", size = 10),
    legend.title = element_blank(),
    legend.position = "right", 
    legend.justification = "left", 
    legend.direction = "vertical",
    plot.margin = margin(50, 100, 100, 50)
  )