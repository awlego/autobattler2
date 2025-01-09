# autobattler2



## Code Architecture

graph TD
	%% Model Layer
	subgraph "Model Layer"
		A1[GameModel] --> B1[BoardModel]
		A1 --> C1[PlayerModel]
		B1 --> D1[TileData]
		B1 --> E1[UnitPositions]
		C1 --> F1[HandModel]
	end

	%% Controller Layer
	subgraph "Controller Layer"
		G1[GameController] --> H1[BoardController]
		G1 --> I1[PlayerController]
		H1 --> J1[TileMapController]
		H1 --> K1[EffectController]
		I1 --> L1[DragDropController]
	end

	%% View Layer
	subgraph "View Layer"
		M1[GameView] --> N1[BoardView]
		M1 --> O1[UIView]
		N1 --> P1[TileMapView]
		N1 --> Q1[EffectLayer]
		O1 --> R1[CardZonesView]
		O1 --> S1[DragDropView]

		%% Detailed View Components
		P1 --> T1[TerrainTiles]
		P1 --> U1[HighlightTiles]
		
		Q1 --> V1[AOEPreview]
		Q1 --> W1[MovementRange]
		
		S1 --> X1[CardSlots]
		S1 --> Y1[SnapPoints]
		
		subgraph "Board Layer (2D)"
			P1
			Q1
			T1
			U1
			V1
			W1
		end
		
		subgraph "UI Layer (CanvasLayer)"
			R1
			S1
			X1
			Y1
		end
	end

	%% Cross-layer connections
	G1 --> A1
	M1 --> G1

	%% Styling
	classDef default fill:#f9f9f9,stroke:#333,stroke-width:1px;
	classDef layer fill:#e1e1e1,stroke:#666,stroke-width:2px;
	classDef model fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
	classDef controller fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px;
	classDef view fill:#f1f8e9,stroke:#2e7d32,stroke-width:2px;
	
	%% Apply styles
	class P1,Q1,T1,U1,V1,W1,R1,S1,X1,Y1 layer;
	class A1,B1,C1,D1,E1,F1 model;
	class G1,H1,I1,J1,K1,L1 controller;
	class M1,N1,O1,P1,Q1,R1,S1,T1,U1,V1,W1,X1,Y1 view;
	
	

## Hex Grid System

### Zone & Hex Structure
- Each zone contains a customizable arrangement of hexagonal slots
- Zones remain distinct gameplay areas (e.g., hand, field, etc.)
- Hex arrangements within zones can form various patterns
- Each hex position represents a potential card slot

### Visual Requirements
- Hex grid must be visible to players
- Support for visual effects including:
  - Hex highlighting
  - Valid move indicators
  - Selection feedback
  - (Future) Special hex state indicators

### Card Interaction
- Each hex position functions as a card slot
- Cards snap to hex centers when placed
- Maintain card swapping functionality:
  - When dropping a card onto an occupied hex, the cards swap positions
  - The displaced card follows the cursor for immediate placement
- (Future) Movement rules and restrictions can be added per zone/card type

### Technical Implementation Notes
The hex grid system should be implemented with a **Custom Drawing Approach**

**Custom Drawing Approach**
   - Pros:
	 - Complete control over hex appearance
	 - Easier to implement custom effects
	 - Direct mapping between visual and logical elements
   - Cons:
	 - More complex to implement initially
	 - May have performance implications for large grids
	 - Manual implementation of all visual features

Recommended approach: **Custom Drawing** with HexMap addon
- Provides better control over card slot integration
- Simplifies implementation of swap mechanics
- More flexible for future visual effects and gameplay mechanics
- Better suited for card game-specific requirements where grid size is limited

	
