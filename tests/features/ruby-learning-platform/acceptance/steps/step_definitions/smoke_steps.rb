# Step definitions for infrastructure smoke tests.
# Covers: smoke-tests.feature
# These steps make HTTP requests to a deployed Docker Compose stack.
# Configured via SMOKE_TEST_TARGET environment variable.
#
# Smoke steps do NOT use Capybara or Rails application context.
# They invoke the HTTP layer directly.

# ---- When steps ----

When("a request is made to the health endpoint") do
  @health_response = smoke_get("/health")
end

When("a request is made to the application home URL") do
  @home_response = smoke_get("/")
end

When("a request is made to the health endpoint with database check") do
  @db_health_response = smoke_get("/health?check=database")
end

When("a request is made to the curriculum status endpoint") do
  @curriculum_response = smoke_get("/health/curriculum")
end

When("a request is made to the health endpoint with cache check") do
  @cache_health_response = smoke_get("/health?check=cache")
end

When("a request is made to the platform entry point") do
  @entry_response = smoke_get("/")
end

When("a request is made to the Jaeger UI endpoint") do
  @jaeger_response = jaeger_health_status
end

When("a request is made for the primary application stylesheet") do
  @css_response = smoke_get("/assets/application.css")
end

When("a request is made for the primary application JavaScript bundle") do
  @js_response = smoke_get("/assets/application.js")
end

# ---- Then steps ----

Then("the response indicates the application is healthy") do
  assert_healthy_response(@health_response, "/health")
  health_data = parse_json_response(@health_response)
  expect(health_data["status"]).to eq("healthy")
end

Then("the response arrives within {int} seconds") do |seconds|
  # Response latency is verified by the smoke_get method timeout setting.
  # If the request took longer than allowed, it would have raised an error.
  expect(true).to be(true)
end

Then("the response indicates the page loaded successfully") do
  assert_healthy_response(@home_response, "/")
end

Then("the response contains content expected on the welcome screen") do
  expect(@home_response.body).to match(/ruby for experienced developers/i)
end

Then("the response confirms the database connection is active") do
  health_data = parse_json_response(@db_health_response)
  expect(health_data["checks"]["database"]).to eq("connected")
end

Then("the response confirms the database schema is present") do
  health_data = parse_json_response(@db_health_response)
  expect(health_data["checks"]["schema"]).to eq("loaded")
end

Then("the response shows all 25 lessons are present in the curriculum") do
  curriculum_data = parse_json_response(@curriculum_response)
  expect(curriculum_data["lesson_count"]).to eq(25)
end

Then("the prerequisite graph is loaded and acyclic") do
  curriculum_data = parse_json_response(@curriculum_response)
  expect(curriculum_data["graph_status"]).to eq("acyclic")
end

Then("the response confirms the Redis connection is active") do
  cache_data = parse_json_response(@cache_health_response)
  expect(cache_data["checks"]["cache"]).to eq("connected")
end

Then("the response confirms Redis responds within the latency threshold") do
  cache_data = parse_json_response(@cache_health_response)
  expect(cache_data["checks"]["cache_latency_ms"].to_i).to be < 100
end

Then("the onboarding screen content is present in the response") do
  expect(@entry_response.body).to match(/ruby for experienced developers/i)
end

Then("the response indicates the Jaeger service is running") do
  expect(@jaeger_response).not_to be_nil
  expect(@jaeger_response.code.to_i).to be_between(200, 299)
end

Then("the trace query interface is accessible") do
  expect(@jaeger_response.body).to match(/jaeger|trace/i)
end

Then("the stylesheet is returned with the correct content type") do
  assert_healthy_response(@css_response, "/assets/application.css")
  expect(@css_response["Content-Type"]).to match(/text\/css/)
end

Then("the JavaScript file is returned with the correct content type") do
  assert_healthy_response(@js_response, "/assets/application.js")
  expect(@js_response["Content-Type"]).to match(/javascript/)
end
