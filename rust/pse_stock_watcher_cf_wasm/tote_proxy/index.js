const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,HEAD,POST,OPTIONS",
  "Access-Control-Max-Age": "86400",
};

addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (url.pathname.startsWith("/stocks")) {
    if (request.method === "OPTIONS") {
      event.respondWith(handlePreflightRequest(request));
    } else if (
      request.method === "GET" || request.method === "HEAD" || request.method === "POST"
    ) {
      if (url.pathname.endsWith("/get_all_stocks")) {
        event.respondWith(getSecuritiesAndIndicesForPublic(request));
      } else if (url.pathname.endsWith("/get_top_active_stocks")) {
        event.respondWith(getTopActiveStocks(request));
      } else if (url.pathname.endsWith("/get_top_security")) {
        event.respondWith(getTopSecurity(request));
      } else if (url.pathname.endsWith("/get_advanced_security")) {
        event.respondWith(getAdvancedSecurity(request));
      } else if (url.pathname.endsWith("/get_declines_security")) {
        event.respondWith(getDeclinesSecurity(request));                
      } else if (url.pathname.endsWith("/get_market_indices")) {
        event.respondWith(getMarketIndices(request));
      } else {
        event.respondWith(getMarketIndices(request));
      }
    }
  } else {
    event.respondWith(handleRequest());
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

async function getMarketIndices(request) {
  let pathQuery = "dailySummary.html?method=getMarketIndices&ajax=true";
  return handleNonPreflightRequest(request, pathQuery);
}

async function getTopActiveStocks(request) {
  let pathQuery = "dailySummary.html?method=getTopActiveStocks&ajax=true";
  return handleNonPreflightRequest(request, pathQuery);
}

async function getTopSecurity(request) {
  let pathQuery = "dailySummary.html?method=getTopSecurity&limit=10&ajax=true";
  return handleNonPreflightRequest(request, pathQuery);
}

async function getAdvancedSecurity(request) {
  let pathQuery = "dailySummary.html?method=getAdvancedSecurity&ajax=true";
  return handleNonPreflightRequest(request, pathQuery);
}

async function getDeclinesSecurity(request) {
  let pathQuery = "dailySummary.html?method=getDeclinesSecurity&ajax=true";
  return handleNonPreflightRequest(request, pathQuery);
}

async function getSecuritiesAndIndicesForPublic(request) {
  let pathQuery = "home.html?method=getSecuritiesAndIndicesForPublic&ajax=true";
  return handleNonPreflightRequest(request, pathQuery);
}

async function findSecurityOrCompany(request) {
  let pathQuery = "home.html?method=findSecurityOrCompany&ajax=true&start=0&limit=1&query=sm";
  return handleNonPreflightRequest(request, pathQuery);
}

async function fetchHeaderData(request) {
  let pathQuery = "companyInfo.html?method=fetchHeaderData&ajax=true&company=599&security=520";
  return handleNonPreflightRequest(request, pathQuery);
}

async function getRecentSecurityQuoteData(request) {
  let pathQuery = "companyInfoHistoricalData.html?method=getRecentSecurityQuoteData&ajax=true&security=520";
  return handleNonPreflightRequest(request, pathQuery);
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

async function handleNonPreflightRequest(request, pathQuery) {
  let baseUrl = "https://www.pse.com.ph/stockMarket/" + pathQuery;

  request = new Request(baseUrl, request);
  request.headers.set("Origin", "http://www.pse.com.ph/stockMarket/home.html");
  request.headers.set("Referer", "http://www.pse.com.ph/stockMarket/home.html");
  request.headers.set("X-Requested-With", "XMLHttpRequest");

  let response = await fetch(request);
  response = new Response(response.body, response);
  response.headers.set("Access-Control-Allow-Origin", "*");
  response.headers.append("Vary", "Origin");
  return response;
}

function handleRequest() {
  return new Response("Tote Proxy", {
    headers: {
      'Content-Type': 'text/plain;charset=UTF-8',
    },
    status: 200,
  });
}
