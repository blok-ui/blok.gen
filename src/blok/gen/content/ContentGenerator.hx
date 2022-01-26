package blok.gen.content;

import Xml;
import haxe.DynamicAccess;
import boxup.Node;
import boxup.schema.Schema;

using Reflect;
using StringTools;

class ContentGenerator {
  public static inline function ofString(str:String) {
    return ofXml(Xml.parse(str));
  }

  public static function ofXml(xml:Xml):Array<Content> {
    function generate(xml:Xml):Array<Content> {
      return ([ for (node in xml) switch node.nodeType {
        case Element if (node.nodeName == 'script'):
          null;
        case Element:
          var props:DynamicAccess<Dynamic> = {};
          for (p in node.attributes()) props[p] = node.get(p);
          new Content({
            type: '@html',
            children: generate(node),
            data: {
              tag: node.nodeName,
              props: props
            }
          });
        case PCData if (node.nodeValue == '\n' || node.nodeValue.trim() == ''): 
          null;
        case PCData:
          new Content({
            type: '@text',
            data: node.nodeValue
          });
        default: null;
      } ]).filter(n -> n != null);
    }
    return generate(xml);
  }

  public static function ofBoxup(schema:Schema, nodes:Array<Node>):Array<Content> {
    function generate(node:Node) return switch node.type {
      case Block(type, _) if (schema.getBlock(type) != null):
        var block = schema.getBlock(type);
        var tag = block.getMeta('html.tag');
        var props = new DynamicAccess();
        var children = node.children.filter(node -> switch node.type {
          case Block(_, _) | Paragraph | Text: true;
          default: false;
        });

        for (prop in block.properties) {
          props.set(prop.name, node.getProperty(prop.name));
        }

        if (tag != null) {
          new Content({
            type: '@html',
            data: {
              tag: tag,
              props: props,
            },
            children: [ for (child in children) generate(child) ]
          });
        } else {
          new Content({
            type: type,
            data: props,
            children: [ for (child in children) generate(child) ]
          });
        }
      case Paragraph:
        new Content({
          type: '@html',
          data: {
            tag: 'p',
            props: {},
          },
          children: [ for (child in node.children) generate(child) ]
        });
      case Text:
        new Content({
          type: '@text',
          data: node.textContent
        });
      default:
        throw 'Unknown type';
    }

    return [ for (node in nodes) generate(node) ].filter(n -> n != null);
  }
}
