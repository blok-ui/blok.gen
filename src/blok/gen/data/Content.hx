package blok.gen.data;

import Xml as HxXml;
import haxe.DynamicAccess;
import blok.VNode;
import blok.VElement;
import blok.VText;

using Reflect;
using StringTools;

/**
  Converts HTML strings into an intermediate JSON representation, which
  can then be safely used as VNodes.
**/
abstract Content({}) from {} {
  @:from public static function ofString(str:String):Content {
    return ofXml(HxXml.parse(str));
  }

  @:from public static function ofXml(xml:HxXml):Content {
    function generate(xml:HxXml):Array<Dynamic> {
      return ([ for (node in xml) switch node.nodeType {
        case Element if (node.nodeName == 'script'):
          null;
        case Element:
          var props:DynamicAccess<Dynamic> = {};
          for (p in node.attributes()) props[p] = node.get(p);
          {
            type: 'node',
            tag: node.nodeName,
            props: props,
            children: generate(node)
          };
        case PCData if (node.nodeValue == '\n' || node.nodeValue.trim() == ''): 
          null;
        case PCData:
          {
            type: 'text',
            content: node.nodeValue
          };
        default: null;
      } ]:Array<Dynamic>).filter(n -> n != null);
    }
    var nodes = generate(xml);
    return switch nodes.length {
      case 0: {
        type: 'none'
      };
      case 1: nodes[0]; 
      default: {
        type: 'fragment',
        children: nodes
      };
    }
  }

  public function new(value) {
    this = value;
  }

  @:to public function toVNode():VNode {
    var json:Dynamic = this;
    return switch json.field('type') {
      case 'none':
        null;
      case 'node':
        VElement.create(json.field('tag'), { 
          attrs: json.field('props'),
          children: (json.field('children'):Array<Content>).map(c -> c.toVNode())
        });
      case 'text':
        new VText(json.field('content'));
      case 'fragment':
        Fragment.node({
          children: (json.field('children'):Array<Content>).map(c -> c.toVNode())
        });
      case other:
        throw 'Invalid node type: $other';
    }
  }
}
