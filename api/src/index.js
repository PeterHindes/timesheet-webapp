/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

async function punch(request, env, ctx) {
	const reqval = await req.json();
	const userID = reqval.userID;
	const punchCatagory = reqval.punchCatagory;

	const sql = `
	BEGIN TRANSACTION;

	WITH latest_punch AS (
			SELECT punchID
			FROM timeCardPunches
			WHERE userID = ? AND punchCatagory = ?
			ORDER BY punchInTime DESC
			LIMIT 1
	)
	UPDATE timeCardPunches
	SET punchOutTime = CURRENT_TIMESTAMP
	WHERE punchID = (SELECT punchID FROM latest_punch) AND punchOutTime IS NULL;

	INSERT INTO timeCardPunches (userID, punchCatagory)
	SELECT ?, ?
	WHERE NOT EXISTS (SELECT 1 FROM latest_punch WHERE punchOutTime IS NULL);

	COMMIT;
	`;

	await env.TSDB.prepare(sql).run(userID, punchCatagory, userID, punchCatagory);

	return new Response("OK");
}

async function punches(request, env, ctx) {
	const reqval = await req.json();
	const userID = reqval.userID;
	const punchCatagory = reqval.punchCatagory;

	const sql = `
	SELECT punchInTime, punchOutTime
	FROM timeCardPunches
	WHERE userID = ? AND punchCatagory = ?
	ORDER BY punchInTime DESC
	LIMIT 10;
	`;

	const rows = await env.TSDB.prepare(sql).all(userID, punchCatagory);

	return new Response(JSON.stringify(rows), {
		headers: { "content-type": "application/json" },
	});
}

async function update(request, env, ctx) {
	const reqval = await request.json();
	const userID = reqval.userID;
	const punchCatagory = reqval.punchCatagory;
	const punchInTime = reqval.punchInTime;
	const punchOutTime = reqval.punchOutTime;

	const sql = `
	UPDATE timeCardPunches
	SET punchInTime = COALESCE(?, punchInTime),
			punchOutTime = COALESCE(?, punchOutTime)
	WHERE userID = ? AND punchCatagory = ?
	AND (punchInTime IS NOT NULL OR punchOutTime IS NOT NULL);
	`;

	await env.TSDB.prepare(sql).run(punchInTime, punchOutTime, userID, punchCatagory);

	return new Response("OK");
}

async function seconds(request, env, ctx) {
	const reqval = await req.json();
	const userID = reqval.userID;
	const punchCatagory = reqval.punchCatagory;
	const startDate = reqval.startDate;
	const endDate = reqval.endDate;

	const sql = `
	SELECT SUM(strftime('%s', punchOutTime) - strftime('%s', punchInTime)) AS totalSeconds
	FROM timeCardPunches
	WHERE userID = ? AND punchCatagory = ? AND punchInTime >= ? AND punchOutTime <= ?
	`;

	const rows = await env.TSDB.prepare(sql).all(userID, punchCatagory, startDate, endDate);

	return new Response(JSON.stringify(rows), {
		headers: { "content-type": "application/json" },
	});
}



const routes = {
	"GET /": () => new Response("This is the api, go to the main site at <a href=\"https://punch.variablef.com\">punch.variablef.com</a>", {
		headers: { "content-type": "text/html" },
	}),
	"POST /punch": punch,
	"GET /punches": punches,
	"GET /seconds": seconds,
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
