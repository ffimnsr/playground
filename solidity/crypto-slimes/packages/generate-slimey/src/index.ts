import {
  Canvas,
  createCanvas,
  loadImage,
  NodeCanvasRenderingContext2D,
} from "canvas";
import {
  LayerKey,
  Layer,
  layersOrder,
  canvasSize,
  Part,
  Metadata,
  Attribute,
  namePrefix,
  description,
  imageBaseUri,
} from "./constants";
import fsp from "fs/promises";
import fs, { Dirent } from "fs";
import path from "path";
import log from "loglevel";
import crypto from "crypto";

const CWD = process.env.INIT_CWD ?? __dirname;

class GenerateSlimey {
  canvas: Canvas;
  canvasContext: NodeCanvasRenderingContext2D;
  count: number;

  outputDir: string = path.join(CWD, "dist");
  assetsDir: string = path.join(CWD, "assets/layers");

  hashMap: Map<string, number> = new Map();

  metadata: Metadata[] = [];
  attributes: Attribute[] = [];
  hash: number[] = [];

  constructor(count: number) {
    this.canvas = createCanvas(canvasSize.width, canvasSize.height);
    this.canvasContext = this.canvas.getContext("2d");
    this.count = count;
  }

  async setup() {
    if (fs.existsSync(this.outputDir)) {
      await fsp.rm(this.outputDir, { recursive: true, force: true });
    }
    await fsp.mkdir(this.outputDir);
  }

  async createMetadataFile() {
    const metadataFile = path.join(this.outputDir, "_metadata.json");

    const stat = await fsp.stat(metadataFile).then(() => true, () => false);
    if (!stat) {
      fsp.writeFile(metadataFile, JSON.stringify(this.metadata, null, 2));
    }
  }

  async createFiles() {
    const layers = this.initLayers();

    let dupeCount = 0;
    for (let i = 1; i <= this.count; i++) {
      layers.forEach(async (layer) => {
        await this.drawElement(layer, i);
      });

      const key = this.hash.toString();
      if (this.hashMap.has(key)) {
        log.error(`Already have duplicate for edition ${i}. Same as edition ${this.hashMap.get(key)}`)
        dupeCount++;

        if (dupeCount > this.count) break;
        i--;
      } else {
        this.hashMap.set(key, i);
        this.addMetadata(i);
        log.info(`Creating nft ${i}`);
      }
    }

    await this.createMetadataFile();
  }

  initLayers() {
    const getPartsDir = (partName: string): string =>
      path.join(this.assetsDir, partName);

    return layersOrder.map(
      (layer: Layer, index: number): LayerKey => ({
        key: index,
        name: layer.name,
        location: getPartsDir(layer.name),
        parts: this.getParts(getPartsDir(layer.name)),
        position: {
          x: 0,
          y: 0,
        },
        size: canvasSize,
        order: 1,
      })
    );
  }

  addMetadata(index: number) {
    let tmp: Metadata = {
        name: `${namePrefix} #${index}`,
        description: description,
        image: `${imageBaseUri}/${index}.png`,
        date: Date.now(),
        edition: index,
        attributes: this.attributes,
    };

    this.metadata.push(tmp);
    this.hash = [];
    this.attributes = [];
  }

  addAttributes(part: Part, layer: LayerKey) {
      let tmp: Attribute = {
        key: part.key,
        layer: layer.name,
        name: part.name,
        rarity: part.weight.toString(),
      };

      this.attributes.push(tmp);
      this.hash.push(layer.key);
      this.hash.push(part.key);
  }

  async drawElement(layer: LayerKey, index: number) {
    let rand = crypto.randomInt(0, index);

    const part = layer.parts[0];
    if (part) {
      this.addAttributes(part, layer);

      const imagePath = path.join(layer.location, `${part.name}.png`);
      const image = await loadImage(imagePath);

      const w = layer.size.width;
      const h = layer.size.width;
      this.canvasContext.drawImage(image, 0, 0, w, h);

      // const outFilepath = path.join(this.outputDir, `${index}.png`);
      // await fsp.writeFile(outFilepath, this.canvas.toBuffer("image/png"));
    }
  }

  getParts(path: string): Part[] {
    return fs
      .readdirSync(path, { withFileTypes: true })
      .filter((dirent: Dirent) => dirent.isFile())
      .map(
        (dirent: Dirent, index: number): Part => ({
          key: index,
          name: dirent.name.split(".")[0],
          filename: dirent.name,
          weight: 0,
        })
      );
  }
}

async function main() {
    let generator = new GenerateSlimey(5);
    await generator.setup();
    await generator.createFiles();
}

main();
