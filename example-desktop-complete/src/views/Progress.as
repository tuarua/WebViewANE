/*
 * Copyright Tua Rua Ltd. (c) 2018.
 */

package views {
import flash.display.Sprite;

public class Progress extends Sprite {
    public function Progress() {
        super();
        this.graphics.beginFill(0x00A3D9);
        this.graphics.drawRect(0,0,800,2);
        this.graphics.endFill();
    }
}
}
