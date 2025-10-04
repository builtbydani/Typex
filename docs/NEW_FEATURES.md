# New Features - Team Builder & Type Coverage Analysis

## Overview
Two major features have been added to the TypeX app to make it a comprehensive strategic companion for Pokémon players:

1. **Team Builder** - Build and analyze teams of up to 6 Pokémon types
2. **Type Coverage Analysis** - Analyze offensive and defensive capabilities of each type

## Team Builder

### Features
- **Build a team of up to 6 members**
  - Each member can have 1-2 types (primary and optional secondary)
  - Add/remove members easily
  - Clear entire team with confirmation

- **Quick Stats per Member**
  - Shows weaknesses, resistances, and immunities for each member
  - Visual stat chips with color coding

- **Team Analysis**
  - Comprehensive team overview with statistics
  - Critical weaknesses detection (types affecting 3+ members)
  - Full breakdown of all weaknesses by type
  - Resistances showing what the team handles well
  - Immunities for complete protection
  - Coverage gaps showing types with no resistance

### How to Use
1. Open the drawer menu or tap the floating action button (group icon)
2. Select "Team Builder"
3. Tap "Add Type" on any of the 6 member slots
4. Select a primary type (required) and optionally a secondary type
5. Tap "Analyze" to see comprehensive team analysis
6. View critical weaknesses and coverage recommendations

### Team Analysis Details
The analysis screen provides:
- **Team Overview**: Member count, total weaknesses, and resistances
- **Critical Weaknesses**: Types that affect 3+ team members (⚠️ warning)
- **Weaknesses**: All types the team struggles against (with member counts)
- **Resistances**: Types the team can handle well
- **Immunities**: Types the team is completely immune to
- **Coverage Gaps**: Types that no team member resists

## Type Coverage Analysis

### Features
- **Comprehensive Type Rankings**
  - Offensive score (how well a type attacks others)
  - Defensive score (how well a type defends)
  - Balanced score (overall effectiveness)

- **Three Sorting Modes**
  - **Offensive**: Best attacking types ranked by super-effective coverage
  - **Defensive**: Best defensive types ranked by resistances
  - **Balanced**: Overall best types considering both aspects

- **Detailed Type Information**
  - Tap any type to see full breakdown
  - Offensive coverage details
  - Defensive coverage details
  - Visual scores with icons

### How to Use
1. Open the drawer menu or tap the floating action button (analytics icon)
2. Select "Type Coverage"
3. Choose sorting mode (Offensive, Defensive, or Balanced)
4. Browse ranked types (top 3 get gold medals!)
5. Tap any type to see detailed breakdown

### Coverage Details
For each type, you can see:
- **Offensive Coverage**
  - Super effective against (×2+)
  - Not very effective against (<×1)
  - No effect against (×0)

- **Defensive Coverage**
  - Weak to (takes ×2+ damage)
  - Resistant to (takes <×1 damage)
  - Immune to (takes ×0 damage)

### Scoring System
- **Offensive Score**: 
  - +2 points per super-effective matchup
  - -1 point per not-effective matchup
  - -2 points per no-effect matchup

- **Defensive Score**:
  - +1 point per resistance
  - +2 points per immunity
  - -2 points per weakness

## Navigation

### Multiple Ways to Access
1. **Drawer Menu** (hamburger icon)
   - Type Chart
   - Team Builder
   - Type Coverage
   - Settings

2. **Floating Action Buttons**
   - Top button: Team Builder (group icon)
   - Bottom button: Type Coverage (analytics icon)

3. **Direct Navigation**
   - From Team Builder → Team Analysis
   - From Type Coverage → Type Details (modal sheet)

## Use Cases

### Team Builder Use Cases
- **Competitive Team Planning**: Build a balanced team with minimal weaknesses
- **Type Synergy**: Find type combinations that complement each other
- **Weakness Coverage**: Identify and patch critical team weaknesses
- **Pre-Battle Preparation**: Analyze opponent team types

### Type Coverage Use Cases
- **Learning Type Matchups**: Understand which types are strongest overall
- **Strategic Planning**: Choose types with best offensive/defensive coverage
- **Type Selection**: Pick the best type for your needs
- **Meta Analysis**: See which types dominate in different aspects

## Technical Implementation

### Architecture
- **MVVM Pattern**: Clean separation of concerns
- **Provider State Management**: Reactive UI updates
- **Shared ViewModels**: Efficient data sharing between screens
- **Responsive Design**: Adapts to different screen sizes

### Key Components
- `TeamBuilderViewModel`: Manages team state and analysis
- `TeamBuilderScreen`: Team building interface
- `TeamAnalysisScreen`: Comprehensive team analysis display
- `TypeCoverageScreen`: Type ranking and coverage analysis

### Performance
- Efficient type effectiveness calculations
- Real-time analysis updates
- Cached type data for fast access
- Minimal memory footprint

## Tips & Best Practices

### Building a Good Team
1. Aim for no more than 1-2 critical weaknesses
2. Try to cover all types with resistances or immunities
3. Balance offensive and defensive capabilities
4. Use dual-type members for better coverage

### Using Type Coverage
1. Start with "Balanced" mode for overall best types
2. Switch to "Offensive" when building an attacking team
3. Switch to "Defensive" for defensive/stall strategies
4. Tap types to see detailed matchup information

### Navigation Tips
- Use floating action buttons for quick access
- Drawer menu shows all available screens
- Back button returns to previous screen
- Team analysis accessible from team builder

## Future Enhancements

Potential additions to these features:
- Save multiple teams
- Team comparison
- Popular Pokémon examples for each type combination
- Export team analysis as image
- Generation-specific type effectiveness
- Move effectiveness with STAB calculations
- Ability considerations (e.g., Levitate, Scrappy)
