require "spec"
require "json"
require "../src/openapi-generator"

struct Model
  extend OpenAPI::Generator::Serializable
  include JSON::Serializable

  property string : String
  property opt_string : String?
  property inner_schema : InnerModel
  @[Field(ignore: true)]
  property ignored : Nil
  @[Field(type: String)]
  @cast : Int32

  def cast
    @cast.to_s
  end

  SCHEMA = <<-JSON
  {
    "required": [
      "string",
      "inner_schema",
      "cast"
    ],
    "type": "object",
    "properties": {
      "string": {
        "type": "string"
      },
      "opt_string": {
        "type": "string"
      },
      "inner_schema": {
        "allOf": [
          {
            "$ref": "#/components/schemas/Model::InnerModel"
          }
        ]
      },
      "cast": {
        "type": "string"
      }
    }
  }
  JSON

  struct InnerModel
    extend OpenAPI::Generator::Serializable
    include JSON::Serializable

    property array_of_int : Array(Int32)

    SCHEMA = <<-JSON
    {
      "required": [
        "array_of_int"
      ],
      "type": "object",
      "properties": {
        "array_of_int": {
          "type": "array",
          "items": {
            "type": "integer"
          }
        }
      }
    }
    JSON
  end

  struct ComplexModel
    extend OpenAPI::Generator::Serializable
    include JSON::Serializable

    property union_types : Int32 | String | Hash(String, InnerModel)
    property free_form : JSON::Any
    property array_of_hash : Array(Hash(String, Int32 | String))

    SCHEMA = <<-JSON
    {
      "required": [
        "union_types",
        "free_form",
        "array_of_hash"
      ],
      "type": "object",
      "properties": {
        "union_types": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": {
                "$ref": "#/components/schemas/Model::InnerModel"
              }
            },
            {
              "type": "integer"
            },
            {
              "type": "string"
            }
          ]
        },
        "free_form": {
          "type": "object",
          "additionalProperties": true
        },
        "array_of_hash": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": {
              "oneOf": [
                {
                  "type": "integer"
                },
                {
                  "type": "string"
                }
              ]
            }
          }
        }
      }
    }
    JSON
  end
end

class Controller
  include OpenAPI::Generator::Controller

  OP_STR = <<-YAML
    tags:
      - tag
    summary: A brief summary of the method.
    requestBody:
      content:
        #{Schema.ref Model}
        #{Schema.ref Model, content_type: "application/x-www-form-urlencoded"}
      required: true
    responses:
      "303":
        description: Operation completed successfully, and redirects to /.
      #{Schema.error 404}
      #{Schema.error 400}
  YAML

  @[OpenAPI(::Controller::OP_STR)]
  def method; end
end
