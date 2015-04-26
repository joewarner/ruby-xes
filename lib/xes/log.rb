module XES
  # Log represents log element of XES.
  class Log
    extend AttributeAccessor

    # @!attribute [rw] concept_name
    #   @return [String]
    #     the value of attribute "concept:name"
    define_attribute "concept:name", "string"

    # @!attribute [rw] lifecycle_model
    #   @return [String]
    #     the value of attribute "lifecycle:model"
    define_attribute "lifecycle:model", "string"

    # @!attribute [rw] semantic_modelReference
    #   @return [String]
    #     the value of attribute "semantic:modelReference"
    define_attribute "semantic:modelReference", "string"

    # @!attribute [rw] identity_id
    #   @return [String]
    #     the value of attribute "identity:id"
    define_attribute "identity:id", "id"

    class << self
      # Create new instance with default values.
      #
      # @return [Log]
      #   new log instance
      def default
        new.tap do |log|
          log.xes_version = "2.0"
          log.xes_features = "nested-attributes"
          log.openxes_version = "1.0RC7"
          log.extensions = [
            EXTENSION[:concept],
            EXTENSION[:identity],
            EXTENSION[:time],
            EXTENSION[:lifecycle],
            EXTENSION[:organizational],
          ]
          log.classifiers = [
            CLASSIFIER[:mxml_legacy_classifier],
            CLASSIFIER[:event_name],
            CLASSIFIER[:resource]
          ]
        end
      end
    end

    # @return [String]
    #   XES version
    attr_accessor :xes_version

    # @return [String]
    #   XES features
    attr_accessor :xes_features

    # @return [String]
    #   openxes version for faking ProM
    attr_accessor :openxes_version

    # @return [String]
    #   xmlns value
    attr_accessor :xmlns

    # @return [Array<Extension>]
    #   XES extensions
    attr_accessor :extensions

    # @return [Array<Classifier>]
    #   XES classifiers
    attr_accessor :classifiers

    # @return [Array<Global>]
    #   XES global elements for event attributes
    attr_accessor :event_global

    # @return [Array<Global>]
    #   XES global elements for trace attributes
    attr_accessor :trace_global

    # @return [Array<Attribute>]
    #   XES attribute elements
    attr_accessor :attributes

    # @return [Array<XESTrace>]
    #   XES trace elements
    attr_accessor :traces

    def initialize
      @xes_version = "2.0"
      @xes_features = ""
      @openxes_version = nil
      @xmlns = "http://www.xes-standard.org/"
      @extensions = []
      @event_global = Global.event
      @trace_global = Global.trace
      @classifiers = []
      @attributes = []
      @traces = []
    end

    # Return true if the element is formattable.
    #
    # @return [Boolean]
    #   true if the element is formattable
    def formattable?
      @traces.any? {|trace| trace.formattable?}
    end

    # Format as a XML element.
    #
    # @return [Nokogiri::XML::Element]
    #   XML element
    # @raise FormatError
    #   format error when the log is formattable
    def format(doc)
      raise FormatError.new(self) unless formattable?

      Nokogiri::XML::Element.new("log", doc).tap do |log|
        log["xes.version"] = @xes_version
        log["xes.features"] = @xes_features
        log["xmlns"] = @xmlns
        log["openxes.version"] = @openxes_version unless @openxes_version == nil
        @extensions.each do |extension|
          log.add_child(extension.format(doc)) if extension.formattable?
        end
        @classifiers.each do |classifier|
          log.add_child(classifier.format(doc)) if classifier.formattable?
        end
        log.add_child(@trace_global.format(doc)) if @trace_global.formattable?
        log.add_child(@event_global.format(doc)) if @event_global.formattable?
        @attributes.each do |attribute|
          log.add_child(attribute.format(doc)) if attribute.formattable?
        end
        @traces.each do |trace|
          log.add_child(trace.format(doc)) if trace.formattable?
        end
      end
    end

    # @api private
    def ==(other)
      return false unless other.kind_of?(self.class)
      return false unless @xes_version == other.xes_version
      return false unless @xes_features == other.xes_features
      return false unless @openxes_version == other.openxes_version
      return false unless @xmlns == other.xmlns
      return false unless @extensions == other.extensions
      return false unless @event_global == other.event_global
      return false unless @trace_global == other.trace_global
      return false unless @classifiers == other.classifiers
      return false unless @attributes == other.attributes
      return false unless @traces == other.traces
      return true
    end
    alias :eql? :"=="

    # @api private
    def hash
      @attributes.hash + @events.hash
    end
  end
end
