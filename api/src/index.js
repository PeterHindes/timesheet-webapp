/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

function punch(request, env, ctx) {
	env.TSDB.prepare("INSERT INTO punches (user, punch) VALUES (?, ?)").run(request.headers.get("user"), request.headers.get("punch"));
}

const routes = {
	"GET /": () => new Response("This is the api, go to the main site at <a href=\"https://lineonline.app\">lineonline.app</a>", {
		headers: { "content-type": "text/html" },
	}),
	"POST /punch": punch,
}

export default {
	async fetch(request, env, ctx) {
		if (request.headers.get("in-the-know") == 'true') {
			const { pathname } = new URL(request.url);
			var route = routes[`${request.method} ${pathname}`];
			console.log("Route", `${request.method} ${pathname}`);
			if (route) {
				return route(request, env);
			}
			return new Response("Not found", { status: 404 });
		} else {
			// drop the request
			// return new Response("Unauthorized", { status: 401 });
			throw new Error("Unauthorized");
		}
	},
};
