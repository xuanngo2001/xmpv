# Quick Styling Cheat Sheet

If you want to tweak the look further, you can edit the tags inside `style_start`, `label_style`, or `value_style`: 

- **Font Size:** Change `\fs22` to a higher or lower number (e.g., `\fs30`). 
- **Colors:** Colors use hexadecimal values in **BGR** format (Blue, Green, Red).
    - Red: `&H0000FF&`
    - Green: `&H00FF00&`
    - Blue: `&HFF0000&`
    - Yellow: `&H00FFFF&` 
- **Positioning:** Change `\an7` to `\an5` to center the text blocks directly in the middle of your video player screen. 

Let me know if you would like to **adjust the positioning** differently, add a **background bounding box** behind the text for better readability, or display **additional metadata** like video resolution or duration!


# 🛠️ How to Customize It Further

1. **Adjusting the Position & Margins:**
    - Look at `\pos(20,20)`. The first number is the **horizontal offset (X)** from the left side of the screen, and the second number is the **vertical offset (Y)** from the top of the screen. Increase these values (e.g., `\pos(50,50)`) to move the text box deeper into the video frame. 
2. **Moving it entirely (e.g., Bottom Left):**
    - If you want to change where it anchors, change `\an7` (Top-Left) to `\an1` (Bottom-Left). If you do this, make sure to adjust your `\pos(X,Y)` accordingly, as Y will now count upwards from the bottom edge of your screen. 
3. **Changing Box Size/Thickness:**
    - Modify `\bord4` to a higher value like `\bord8` to make the surrounding background box thicker and roomier.