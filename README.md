# gestures-in-conversations
This repository provides an data and R-scripts for an ongoing project examining the role of co-speech gestures in conversation coordination between adults and children (7- to 11-yo).

The main objective of this project is to compare the different co-speech gesture types used by children and their parents during conversation (word guessing game).

## Annotations
We annotated video recordings of 6 child-parent pairs from the CHICA corpus (Goumri et al. 2024). 

The co-speech gestures of the child and their parent were annotated and categorized into four different gesture types: iconic, deictic, non-referential, and conventional (Kendon, 2004; McNeill 1992). Additionally, we annotated the accompanying vocal modality (speech and other vocalizations) to examine gestures-vocal modality alignment in the children and their parents. In the vocal modality, we annotated : word (gesture before after or during a particular word or a short phrase is uttered; the gesture token has a corresponding component to the speech token produced), sentence (gesture produced while uttering a full sentence), no speech (gesture produced without any speech but during the conversation), end (gesture produced at the end of a sentence), vocal (gesture produced with a non-speech vocalization like err, aah, hmm etc.), other (gesture produced before during or after a word or a sentence but the speech component did not have any corresponding token of the gesture; rather, the gesture added extra meaning to the utterance).

[Download the dataset](data.csv)

## Hypotheses
H1: Children would use certain descriptive gestures to compensate for the lack of their vocabulary
H2: Overall, children and their parents will mutually mirror or adapt to their gesture profiles

## Analyses
Raw data from annotation software (ELAN Version 6.7, Max Planck Institute for Psycholinguistics 2023) were transformed into long format to carry out descriptive statistical tests to compare the average proportions of all gesture types,  body parts used to produce the gestures and accompanying vocal modality (speech and other vocalisations) between children and their parents during face-to-face conversations.

Additionally, we carrie dout a dimensionality reduction technique using UMAP (Uniform Manifold Approximation and Projection) to allow visual inspection of clustering tendencies and similarities or differences in gesture–speech pairings between adults and children.


[Download R-script](gestures_in_conversations.R)

## Findings (so far)
1.
<img width="375" height="217" alt="image" src="https://github.com/user-attachments/assets/770869a9-32c5-496e-8b23-91fd1e998cea" />

Overall, children used significantly more deictic (mean = 0.1 ± SE 0.03; t(df) = 2.3 (12), p = 0.04) and iconic gestures (mean = 0.85 ± SE 0.03; t(df) = 21.78 (32), p < 0.0001) than the parents. This alings with our first hypothesis.

2.
<img width="468" height="214" alt="image" src="https://github.com/user-attachments/assets/a2c72512-6b0d-45b8-b25b-69f8138cfa84" />

Overall, adults and children use similar body parts to produce similar gesture types. However, subtle differences were noticed, such as adults producing deictic gestures with their heads (e.g. tilting head in a specific direction to indicate an object, much like pointing), while children sometimes use iconic gestures using the whole body, unlike the adults.

3.
<img width="442" height="204" alt="image" src="https://github.com/user-attachments/assets/ef8f6d9c-cf02-4d9c-937d-b55f62536096" />

Overall, similar profiles in the adults and the children regarding the gesture-speech alignments. Children use all gesture types with no speech (perhaps, because they do not have the corresponding vocabulary and thus replacing by the gestures). Interestingly, adults are using almost all gesture types in the other speech category, thus they are adding meaning from gestures to their speech and thus balancing between the modalities.

4.
<img width="457" height="258" alt="image" src="https://github.com/user-attachments/assets/63623eb6-c0bd-4a49-b36f-44e6ff4a44a6" />

If we look across the profiles of the children and the adults, despite a general abundance of non-referential gestures in adults and conventional gestures in the children, it is obvious that there are considerable differences of
gesture profiles between child-parent pairs, while the profiles are quite similar within a pairit is also obvious that there are considerable individual differences. This aligns with our second hypothesis. We also ran a similarity index analses for each child-parent pair.  We found, in each child–parent pair, across gesture types, the profiles were generally similar: absolute difference scores were consistently low, and ratios often hovered near one. This was especially evident for pairs like C10–A10 and C5–A5. While some variation appeared across dyads, many showed parallel use of gesture types, particularly non-referential and conventional gestures. In contrast, some pairs did not mirror each other — for example, in C3–A3, the child used non-referential gestures much less than the adult. These analyses should be further carried out with a larger sample size to compare across child-parent pairs.

5.
<img width="454" height="288" alt="image" src="https://github.com/user-attachments/assets/376a3c34-13f6-472e-9783-e52ca4eb7a24" />

What is striking here is the higher use of non-referential gestures either with sentence or at the end of sentences in adults than in children. Perhaps these pragmatic gestures are increasing with age, especially becoming more salient in cases of giving 

{This project was done in collaboration with Enrique Bustamante (master's dissertation, 2025) and Abdellah Fourtassi,  Aix-Marseille Université}



turns (using gestures at the end). Similarly, association of conventional gestures and words are higher in adults than in the children. Interestingly, children use all gesture types in isolation (no speech condition), higher than by adults. Thus, the gesture-vocal alignment is perhaps still developing at this stage. It is also noticeable that the adults are capable of using gestures to add complementary information to their speech (other condition) more than the children could.
