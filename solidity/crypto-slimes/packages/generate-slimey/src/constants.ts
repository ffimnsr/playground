export const namePrefix = "Collection";
export const description = "The description";
export const imageBaseUri = "ipfs://asdasd";

export interface Layer {
    name: string;
}

export const layersOrder: Layer[] = [
    { name: "Background" },
    { name: "Bottom lid" },
    { name: "Eye color" },
    { name: "Eyeball" },
    { name: "Goo" },
    { name: "Iris" },
    { name: "Shine" },
    { name: "Top lid" },
];

export interface CanvasPosition {
    x: number;
    y: number;
}

export interface CanvasSize {
    width: number;
    height: number;
}

export const canvasSize: CanvasSize = {
    width: 250,
    height: 250,
};

export interface Rarity {
    postfix: string;
    value: string;
}

export const rarities = [
    { postfix: "", value: "Normal" },
    { postfix: "_r", value: "Rare" },
    { postfix: "_sr", value: "Super Rare" },
];

export interface Part {
    key: number;
    name: string;
    filename: string;
    weight: number;
}

export interface LayerKey {
    key: number;
    name: string;
    location: string;
    parts: Part[];
    position: CanvasPosition;
    size: CanvasSize;
    order: number;
}

export interface Attribute {
    key: number;
    layer: string;
    trait_type: string;
    value: string;
}

export interface Metadata {
    hash: string;
    name: string;
    description: string;
    image: string;
    background_color: string;
    external_url: string;
    edition: number;
    date: number;
    attributes: Attribute[];
}
