#!/bin/bash
SRC_DIR="/Users/lithinknasani/.gemini/antigravity/brain/a85b884e-4bb4-49e1-ba5d-d00c86b6e340"
DEST_DIR="/Users/lithinknasani/Documents/GitHub/memoriz/assets/images"

mkdir -p "$DEST_DIR"

cp "$SRC_DIR/sacred_morning_bg_1776851254703.png" "$DEST_DIR/bg_morning.png"
cp "$SRC_DIR/quiet_devotion_bg_1776851283229.png" "$DEST_DIR/bg_devotion.png"
cp "$SRC_DIR/midnight_star_bg_1776852215684.png" "$DEST_DIR/bg_star.png"
cp "$SRC_DIR/emerald_forest_bg_1776852242679.png" "$DEST_DIR/bg_forest.png"
cp "$SRC_DIR/ancient_parchment_bg_1776852269736.png" "$DEST_DIR/bg_parchment.png"
cp "$SRC_DIR/white_marble_bg_1776852292980.png" "$DEST_DIR/bg_marble.png"
cp "$SRC_DIR/sunset_horizon_bg_1776852318767.png" "$DEST_DIR/bg_sunset.png"
cp "$SRC_DIR/lavender_clouds_bg_1776852349177.png" "$DEST_DIR/bg_clouds.png"
cp "$SRC_DIR/minimal_dunes_bg_1776852380669.png" "$DEST_DIR/bg_dunes.png"
cp "$SRC_DIR/living_water_bg_1776852463586.png" "$DEST_DIR/bg_water.png"

echo "Images copied successfully"
