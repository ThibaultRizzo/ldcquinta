# LDC Quinta - Accompagnement Installation en France 🇫🇷

Plateforme d'aide pour les étudiants et travailleurs étrangers s'installant en France.

## 📁 Structure du Projet

- **index.html** - Page d'accueil / Landing page
- **quiz.html** - Questionnaire multi-étapes (4 étapes)
- **dashboard.html** - Dashboard avec checklist personnalisée (accessible via formule "Advanced")

## 🚀 Utilisation

### Ouvrir le projet dans Chrome

```bash
# Ouvrir la landing page
make open
# ou
make chrome

# Ouvrir directement le dashboard
make dashboard

# Voir toutes les commandes disponibles
make help
```

## 📋 Fonctionnalités

### Page d'Accueil (index.html)
- Présentation du projet
- Information sur le questionnaire (4 étapes, 2-3 minutes, 12 questions)
- Bouton "Suivant" pour commencer le questionnaire

### Questionnaire (quiz.html)
- **Étape 1 - Profil** : Statut, nationalité, niveau de français
- **Étape 2 - Séjour** : Durée, date d'arrivée, ville
- **Étape 3 - Besoins** : Logement, visa, type d'accompagnement
- **Étape 4 - Offres** : 3 formules (Basic, Advanced, Pro)

### Dashboard (dashboard.html)
- Checklist organisée par catégories :
  - 📞 Communication (eSIM, Internet box)
  - 💰 Finance (Bank account)
  - 🚇 Transport (Navigo, Velib)
  - 📋 Admin assistance (CAF)
  - 🛡️ Insurance (Health, Home)
  - ✈️ Upon arrival (Airport pickup, Apartment rental)
  - 🤝 Social (Integration event)
- Statuts visuels : Done ✓, Pending ⏳, Not needed −
- Boutons d'action pour les items en attente

## 🎨 Design

- Interface moderne et responsive
- Animations fluides
- Gradient violet/bleu
- Mobile-friendly

## 🔄 Navigation

1. **index.html** → Bouton "Suivant" → **quiz.html**
2. **quiz.html** (Étape 4) → Bouton "Advanced" → **dashboard.html**

