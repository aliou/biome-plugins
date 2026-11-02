import {
    type Component,
    Container,
    Text,
} from "@earendil-works/pi-tui";
import { truncateToWidth } from "./truncate";

class Example {
    private contentText: Text;

    constructor() {
        this.contentText = new Text(truncateToWidth("Imported component", 80), 0, 0);
    }

    render(): Component {
        const container = new Container();
        container.addChild(this.contentText);
        return container;
    }
}
