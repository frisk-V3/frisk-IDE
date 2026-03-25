package com.editor;

import org.fxmisc.richtext.CodeArea;
import com.editor.SyntaxHighlighter;
import com.editor.CompletionProvider;
import com.editor.EditorDocument;

public class EditorPane extends CodeArea {

    private final EditorDocument document;
    private final SyntaxHighlighter highlighter;
    private final CompletionProvider completion;

    public EditorPane(EditorDocument doc,
                      SyntaxHighlighter highlighter,
                      CompletionProvider completion) {

        this.document = doc;
        this.highlighter = highlighter;
        this.completion = completion;

        setParagraphGraphicFactory(LineNumberGutter::create);

        // 入力時にハイライト
        textProperty().addListener((obs, old, now) -> {
            setStyleSpans(0, highlighter.highlight(now));
        });

        // 補完呼び出し
        setOnKeyPressed(e -> {
            switch (e.getCode()) {
                case SPACE -> {
                    if (e.isControlDown()) {
                        completion.showPopup(this);
                    }
                }
            }
        });
    }
}
