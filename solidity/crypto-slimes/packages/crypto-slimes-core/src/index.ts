import { Router, Request } from "itty-router";

const router = Router();

router.get("/", () => {
    return new Response("Hello, world!", {
        headers: {
            "content-type": "text-plain",
        },
    });
});

router.get("/api/item/:id.json", ({ params }: Request) => {
    const input = decodeURIComponent(params?.id ?? "");
    const buffer = Buffer.from(input, "utf8");
    const base64 = buffer.toString("base64");
    return new Response(`<p>Base64 encoding: <code>${base64}</code></p>`, {
        headers: {
            "Content-Type": "text/html",
        },
    });
});

router.all("*", () => new Response("404, not found!", { status: 404 }));

addEventListener("fetch", (event) => {
    event.respondWith(router.handle(event.request));
});
