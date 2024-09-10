const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,HEAD,POST,OPTIONS",
  "Access-Control-Max-Age": "86400",
};

addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (url.pathname.startsWith("/proxy")) {
    if (request.method === "OPTIONS") {
      event.respondWith(handlePreflightRequest(request));
    } else if (
      request.method === "GET"
      || request.method === "HEAD"
      || request.method === "POST"
    ) {
      event.respondWith(handleNonPreflightRequest(request));
    }
  } else if (url.pathname.startsWith("/test")) {
    event.respondWith(handleTestRequest(request));
  } else if (url.pathname.startsWith("/get_all_stocks")) {
    event.respondWith(handleGetAllStocksRequest(request));
  } else if (url.pathname.startsWith("/get_stock")) {
    event.respondWith(handleGetStockRequest(request));
  } else if (url.pathname.startsWith("/get_stock_by_date")) {
    event.respondWith(handleGetStockByDateRequest(request));
  } else if (url.pathname.startsWith("/archive")) {
    event.respondWith(handleArchiveRequest(request));         
  } else {
    event.respondWith(handleRequest(request));
  }  
});

function handleRequest() {
  return new Response("Tote", {
    headers: {
      'Content-Type': 'text/plain;charset=UTF-8',
    },
    status: 200,
  });
}

async function handleNonPreflightRequest(request) {
  const url = new URL(request.url);
  let apiUrl = url.searchParams.get("url");

  request = new Request(apiUrl, request);
  request.headers.set("Origin", new URL(apiUrl).origin);

  let response = await fetch(request);
  response = new Response(response.body, response);
  response.headers.set("Access-Control-Allow-Origin", url.origin);
  response.headers.append("Vary", "Origin");
  return response;
}

function handlePreflightRequest(request) {
  let headers = request.headers;
  if (headers.get("Origin") !== null
    && headers.get("Access-Control-Request-Method") !== null
    && headers.get("Access-Control-Request-Headers") !== null
  ) {
    let respHeaders = {
      ...corsHeaders,
      "Access-Control-Allow-Headers": request.headers.get("Access-Control-Request-Headers"),
    };

    return new Response(null, {
      headers: respHeaders,
    });
  } else {
    return new Response(null, {
      headers: {
        Allow: "GET, HEAD, POST, OPTIONS",
      },
    });
  }
}

async function handleTestRequest(request) {
  const { test } = wasm_bindgen;
  await wasm_bindgen(wasm);

  const data = await test();
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
    status: 200,
  });
}

async function handleGetAllStocksRequest(request) {
  const { get_all_stocks } = wasm_bindgen;
  await wasm_bindgen(wasm);

  const data = await get_all_stocks();
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
    status: 200,
  });
}

async function handleGetStockRequest(request) {
  const url = new URL(request.url);
  let symbol = url.searchParams.get("symbol");

  const { get_stock } = wasm_bindgen;
  await wasm_bindgen(wasm);

  const data = await get_stock(symbol);
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
    status: 200,
  });
}

async function handleGetStockByDateRequest(request) {
  const url = new URL(request.url);
  let symbol = url.searchParams.get("symbol");
  let timestamp = url.searchParams.get("timestamp");

  const { get_stock_by_date } = wasm_bindgen;
  await wasm_bindgen(wasm);

  const data = await get_stock_by_date(symbol, timestamp);
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
    status: 200,
  });
}

async function handleArchiveRequest(request) {
  const { archive } = wasm_bindgen;
  await wasm_bindgen(wasm);

  const data = await archive();
  return new Response(JSON.stringify(data), {
    headers: {
      'Content-Type': 'application/json;charset=UTF-8',
    },
    status: 200,
  });
}